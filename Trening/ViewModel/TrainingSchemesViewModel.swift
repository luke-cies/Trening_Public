//
//  TrainingSchemesViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 27/03/2023.
//

import Foundation

protocol TrainingSchemesViewModelProtocol{
    var currentTrainingScheme: EditTrainingScheme {get}
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme)
    mutating func refreshCurrentTrainingScheme()
    var trainingSchemes: [TrainingScheme] {get}
    func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingScheme?) -> Void)
    func removeTrainingScheme(at indexPath: IndexPath, completion: @escaping (TrainingSchemeError?) -> Void)
    func updateTrainingScheme(_ scheme: EditTrainingScheme, completion: @escaping (TrainingSchemeError?) -> Void)
    func addSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?, TrainingSchemeData?) -> Void)
    func updateSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void)
    func removeSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void)
    var loggedUserId: String {get}
}

struct EditTrainingScheme: TrainingSchemeProtocol{
    var id: String
    var trainingMethod: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    var trainingType: TrainingType
    var userId: String
    var trainingSchemeData: [TrainingSchemeData]
    static func numberOfWorkoutsDescription(_ numberOfWorkouts: Int) -> String {
        TrainingScheme.numberOfWorkoutsDescription(numberOfWorkouts)
    }
    
    init(withTrainingScheme scheme: TrainingScheme){
        id = scheme.id
        trainingMethod = scheme.trainingMethod
        name = scheme.name.count > 0 ? scheme.name : "trainingScheme.add.name".localized
        numberOfWorkouts = scheme.numberOfWorkouts
        trainingType = scheme.trainingType
        userId = scheme.userId
        trainingSchemeData = scheme.trainingSchemeData
    }
    
    func trainingScheme() -> TrainingScheme{
        var s = TrainingScheme(trainingMethod: trainingMethod, name: name, numberOfWorkouts: numberOfWorkouts, trainingType: trainingType, userId: userId, trainingSchemeData: trainingSchemeData)
        s.id = id
        
        return s
    }
}

struct TrainingSchemesViewModel{
    private var _currentTrainingScheme: EditTrainingScheme!
}

extension TrainingSchemesViewModel: TrainingSchemesViewModelProtocol{
    var trainingSchemes: [TrainingScheme]{
        Service.trainingSchemes
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
    
    func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingScheme?) -> Void) {
        Service.createTrainingScheme(credentials, completion: completion)
    }
    
    func updateTrainingScheme(_ scheme: EditTrainingScheme, completion: @escaping (TrainingSchemeError?) -> Void) {
        Service.updateTrainingScheme(scheme.trainingScheme(), completion: completion)
    }
    
    func removeTrainingScheme(at indexPath: IndexPath, completion: @escaping (TrainingSchemeError?) -> Void) {
        let scheme = trainingSchemes[indexPath.row]
        Service.removeTrainingScheme(scheme, completion: completion)
    }
    
    func addSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?, TrainingSchemeData?) -> Void) {
        let credentials = TrainingSchemeDataCredentials(trainingSchemeId: currentTrainingScheme.id, exercise: data.exercise, numberOfSeries: data.numberOfSeries, weight: data.weight, addWeight: data.addWeight)
        Service.createTrainingSchemeData(credentials, completion: completion)
    }
    
    func updateSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void) {
        Service.updateTrainingSchemeData(data, completion: completion)
    }
    
    func removeSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void) {
        Service.removeTrainingSchemeData(data, completion: completion)
    }
}

