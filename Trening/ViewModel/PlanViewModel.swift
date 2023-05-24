//
//  PlanViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/05/2023.
//

import Foundation

protocol PlanViewModelProtocol{
    var count: Int {get}
    var currentTrainingScheme: EditTrainingScheme {get}
    subscript(index: Int) -> TrainingScheme? {get set}
    func removeTraining(at indexPath: IndexPath, completion: @escaping (TrainingSchemeError?) -> Void)
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme)
}

struct PlanViewModel{
    private var _trainings: [TrainingScheme]
    private var _currentTraining: EditTrainingScheme!
    
    init(){
        _trainings = Service.trainingSchemes.filter({ $0.trainingType == .plan })
    }
}

//MARK: - PlanViewModelProtocol
extension PlanViewModel: PlanViewModelProtocol{
    subscript(index: Int) -> TrainingScheme? {
        get {
            if index >= _trainings.count {return nil}
            return _trainings[index]
        }
        set {
            if index < _trainings.count, let nVal = newValue{
                _trainings[index] = nVal
            }
        }
    }
    
    var count: Int{
        _trainings.count
    }
    
    var currentTrainingScheme: EditTrainingScheme{
        _currentTraining
    }
    
    func removeTraining(at indexPath: IndexPath, completion: @escaping (TrainingSchemeError?) -> Void) {
        let training = _trainings[indexPath.row]
        Service.removeTrainingScheme(training, completion: completion)
    }
    
    mutating func currentTrainingScheme(_ scheme: EditTrainingScheme) {
        _currentTraining = scheme
    }
}
