//
//  PlanViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/05/2023.
//

import Foundation

typealias PlanViewCompletion = ApiTrainingSchemeCompletion
typealias AddTrainingPlanCompletion = ApiAddTrainingSchemeCompletion
typealias TrainingPlanDataCompletion = ApiAddTrainingDataSchemeCompletion
typealias TrainingPlanRunCompletion = (TrainingError?) -> Void

protocol PlanViewModelProtocol{
    var count: Int {get}
    var currentTrainingScheme: EditTrainingScheme {get}
    var loggedUserId: String {get}
    subscript(index: Int) -> TrainingScheme? { get }
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme)
    mutating func refreshCurrentTrainingScheme()
    func addTrainingPlan(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping AddTrainingPlanCompletion)
    func removeTrainingPlan(at indexPath: IndexPath, completion: @escaping PlanViewCompletion)
    func updateTrainingPlan(_ scheme: EditTrainingScheme, completion: PlanViewCompletion?)
    func addPlanData(_ data: TrainingSchemeData, completion: @escaping TrainingPlanDataCompletion)
    func updatePlanData(_ data: TrainingSchemeData, completion: @escaping PlanViewCompletion)
    func removePlanData(_ data: TrainingSchemeData, completion: @escaping PlanViewCompletion)
    mutating func loadScheme(_ data: TrainingScheme)
    func runCurrentPlan(_ completion: @escaping TrainingPlanRunCompletion)
}

struct PlanViewModel{
    private var _trainings: [TrainingScheme] { Service.trainingSchemes.filter({ $0.trainingType == .plan }).sorted{ $0.timestamp < $1.timestamp } }
    private var _currentTraining: EditTrainingScheme!
}

//MARK: - PlanViewModelProtocol
extension PlanViewModel: PlanViewModelProtocol{
    subscript(index: Int) -> TrainingScheme? {
        if index >= _trainings.count {return nil}
        return _trainings[index]
    }
    
    var count: Int{
        _trainings.count
    }
    
    var currentTrainingScheme: EditTrainingScheme{
        _currentTraining
    }
    
    var loggedUserId: String {
        guard let user = Service.loggedInUser() else{ return String()}
        return user.userId
    }
    
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme) {
        _currentTraining = scheme
    }
    
    mutating func refreshCurrentTrainingScheme() {
        let schemeUid = _currentTraining.id
        if let scheme = Service.trainingSchemes.first(where: { $0.id == schemeUid }) {
            _currentTraining = .init(withTrainingScheme: scheme)
        }
    }
    
    func addTrainingPlan(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping AddTrainingPlanCompletion) {
        Service.createTrainingScheme(credentials, completion: completion)
    }
    
    func removeTrainingPlan(at indexPath: IndexPath, completion: @escaping PlanViewCompletion) {
        var training = _trainings[indexPath.row]
        training.isRemoved = true
        Service.removeTrainingScheme(training, completion: completion)
    }
    
    func updateTrainingPlan(_ scheme: EditTrainingScheme, completion: PlanViewCompletion?) {
        Service.updateTrainingScheme(scheme.trainingScheme(), completion: completion)
    }
    
    func addPlanData(_ data: TrainingSchemeData, completion: @escaping TrainingPlanDataCompletion) {
        let credentials = TrainingSchemeDataCredentials(trainingSchemeId: currentTrainingScheme.id, exercise: data.exercise, numberOfSeries: data.numberOfSeries, weight: data.weight, addWeight: data.addWeight, trainingType: data.trainingType)
        Service.createTrainingSchemeData(credentials, completion: completion)
    }
    
    func removePlanData(_ data: TrainingSchemeData, completion: @escaping PlanViewCompletion) {
        var tmpData = data
        tmpData.isRemoved = true
        Service.removeTrainingSchemeData(tmpData, completion: completion)
    }
    
    func updatePlanData(_ data: TrainingSchemeData, completion: @escaping PlanViewCompletion) {
        Service.updateTrainingSchemeData(data, completion: completion)
    }
    
    mutating func loadScheme(_ data: TrainingScheme) {
        var newScheme = data.copy()
        newScheme.trainingType = .plan
        newScheme.userId = String() //it will create new planned training
        
        let newSchemeData = newScheme.trainingSchemeData.map { data in
            var d = data.copy()
            d.trainingType = .plan
            
            return d
        }
        newScheme.trainingSchemeData = newSchemeData
        currentTrainingScheme(.init(withTrainingScheme: newScheme))
    }
    
    func runCurrentPlan(_ completion: @escaping TrainingPlanRunCompletion) {
        var modifiedWeightCounter: CGFloat = 0.0
        for i in (1..._currentTraining.numberOfWorkouts).reversed() {
            let trCredentials: TrainingCredentialsProtocol = TrainingCredentials(trainingCounter: i, 
                                                                                 plannedNumberOfWorkouts: currentTrainingScheme.numberOfWorkouts,
                                                                                 subType: currentTrainingScheme.subType,
                                                                                 trainingData: [TrainingDataCredentialsProtocol](),
                                                                                 trainingMethod: currentTrainingScheme.trainingMethod,
                                                                                 planId: currentTrainingScheme.id,
                                                                                 userId: currentTrainingScheme.userId)
            
            Service.createTraining(trCredentials) { (error: TrainingError?, tr: Training?) in
                if let error = error {
                    completion(error)
                    return
                }
                if let tr = tr {
                    currentTrainingScheme.trainingSchemeData.forEach { (schemeData: TrainingSchemeData) in
                        var modifiedWeight: CGFloat = modifiedWeightCounter * schemeData.addWeight
                        modifiedWeight = modifiedWeight < 0 ? 0 : modifiedWeight
                        
                        let data: TrainingDataCredentialsProtocol = TrainingCredentials.TrainingDataCredentials(trainingId: tr.id,
                                                                                                                exercise: schemeData.exercise,
                                                                                                                exerciseOrder: schemeData.exerciseOrder,
                                                                                                                plannedNumberOfSeries: schemeData.numberOfSeries,
                                                                                                                plannedWeight: schemeData.weight - modifiedWeight)
                        Service.createTrainingData(data) { (error: TrainingError?, trData: TrainingData?) in
                            if let error = error {
                                completion(error)
                                return
                            }
                        }
                    }
                    modifiedWeightCounter += 1.0
                }
            }
        }
        completion(nil)//ready
    }
}
