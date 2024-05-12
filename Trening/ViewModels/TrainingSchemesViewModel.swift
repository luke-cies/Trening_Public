//
//  TrainingSchemesViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 27/03/2023.
//

import Foundation

typealias AddTrainingSchemesCompletion = ApiAddTrainingSchemeCompletion
typealias TrainingSchemesCompletion = ApiTrainingSchemeCompletion
typealias TrainingSchemesDataCompletion = ApiAddTrainingDataSchemeCompletion

protocol TrainingSchemesViewModelProtocol{
    var currentTrainingScheme: EditTrainingScheme {get}
    var loggedUserId: String {get}
    var trainingSchemes: [TrainingScheme] {get}
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme)
    mutating func refreshCurrentTrainingScheme()
    func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping AddTrainingSchemesCompletion)
    func removeTrainingScheme(at indexPath: IndexPath, completion: @escaping TrainingSchemesCompletion)
    func updateTrainingScheme(_ scheme: EditTrainingScheme, completion: TrainingSchemesCompletion?)
    func addSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesDataCompletion)
    func updateSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesCompletion)
    func removeSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesCompletion)
    mutating func moveSchemeData(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath)
}

struct EditTrainingScheme: TrainingSchemeProtocol{
    var id: String
    var trainingMethod: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    var trainingType: TrainingType
    var userId: String
    var trainingSchemeData: [TrainingSchemeData]
    let isNew: Bool
    static func numberOfWorkoutsDescription(_ numberOfWorkouts: Int) -> String {
        TrainingScheme.numberOfWorkoutsDescription(numberOfWorkouts)
    }
    
    init(withTrainingScheme scheme: TrainingScheme){
        id = scheme.id
        trainingMethod = scheme.trainingMethod
        name = scheme.name.count > 0 ? scheme.name : "trainingScheme.add.defaultName".localized
        numberOfWorkouts = scheme.numberOfWorkouts
        trainingType = scheme.trainingType
        userId = scheme.userId
        trainingSchemeData = scheme.trainingSchemeData
        isNew = scheme.name.count == 0
    }
    
    func trainingScheme() -> TrainingScheme{
        var s = TrainingScheme(trainingMethod: trainingMethod, name: name, numberOfWorkouts: numberOfWorkouts, trainingType: trainingType, userId: userId, trainingSchemeData: trainingSchemeData)
        s.id = id
        
        return s
    }
}

struct TrainingSchemesViewModel{
    private var _currentTrainingScheme: EditTrainingScheme!
    
    //MARK: - Private
    private mutating func updateExercisesOrder(_ data: inout [TrainingSchemeData]){
        var updatedData = [TrainingSchemeData]()
        data.enumerated().forEach { (index, value) in
            var updatedValue = value
            updatedValue.exerciseOrder = index
            updatedData.append(updatedValue)
        }
        
        data = updatedData
    }
}

//MARK: - TrainingSchemesViewModelProtocol
extension TrainingSchemesViewModel: TrainingSchemesViewModelProtocol{
    var trainingSchemes: [TrainingScheme]{
        Service.trainingSchemes.filter({ $0.trainingType == .scheme }).sorted { $0.timestamp < $1.timestamp }
    }
    var currentTrainingScheme: EditTrainingScheme{
        _currentTrainingScheme
    }
    
    var loggedUserId: String{
        guard let user = Service.loggedInUser() else{ return String()}
        return user.userId
    }
    
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme) {
        _currentTrainingScheme = scheme
    }
    
    mutating func refreshCurrentTrainingScheme() {
        let schemeUid = _currentTrainingScheme.id
        if let scheme = Service.trainingSchemes.first(where: { $0.id == schemeUid }) {
            _currentTrainingScheme = .init(withTrainingScheme: scheme)
        }
    }
    
    func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping AddTrainingSchemesCompletion) {
        Service.createTrainingScheme(credentials, completion: completion)
    }
    
    func updateTrainingScheme(_ scheme: EditTrainingScheme, completion: TrainingSchemesCompletion?) {
        Service.updateTrainingScheme(scheme.trainingScheme(), completion: completion)
    }
    
    func removeTrainingScheme(at indexPath: IndexPath, completion: @escaping TrainingSchemesCompletion) {
        var scheme = trainingSchemes[indexPath.row]
        scheme.isRemoved = true
        Service.removeTrainingScheme(scheme, completion: completion)
    }
    
    func addSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesDataCompletion) {
        let credentials = TrainingSchemeDataCredentials(trainingSchemeId: currentTrainingScheme.id, exercise: data.exercise, numberOfSeries: data.numberOfSeries, weight: data.weight, addWeight: data.addWeight, trainingType: data.trainingType)
        Service.createTrainingSchemeData(credentials, completion: completion)
    }
    
    func updateSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesCompletion) {
        Service.updateTrainingSchemeData(data, completion: completion)
    }
    
    func removeSchemeData(_ data: TrainingSchemeData, completion: @escaping TrainingSchemesCompletion) {
        var tmpData = data
        tmpData.isRemoved = true
        Service.removeTrainingSchemeData(tmpData, completion: completion)
    }
    
    mutating func moveSchemeData(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        var exercises: [TrainingSchemeData] = _currentTrainingScheme.trainingSchemeData
        exercises.swapAt(sourceIndexPath.row, destinationIndexPath.row)
        
        updateExercisesOrder(&exercises)
        
        _currentTrainingScheme.trainingSchemeData = exercises
        updateTrainingScheme(_currentTrainingScheme, completion: nil)
    }
}

