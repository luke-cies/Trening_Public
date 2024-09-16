//
//  TrainingViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/05/2024.
//

import Foundation

protocol TrainingViewModelProtocol: TrainingViewModelRunProtocol {
    var allTrainings: [Training] {get}
    subscript(index: Int) -> Training? { get }
    
    mutating func refreshCurrentTraining()
    mutating func setCurrentTraining(_ training: Training)
}

protocol TrainingViewModelRunProtocol {
    var currentTraining: Training { get }
    var currentTrainingData: TrainingData { get }
    
    func addSerie()
    func nextExercise()
    func previousExercise()
    func saveData()
    func finishTraining()
}

struct EditTraining: TrainingProtocol {
    let userId: String
    let id: String
    var status: TrainingStatus
    var trainingMethod: TrainingMethod
    var trainingCounter: Int
    let plannedNumberOfWorkouts: Int
    let createDate: Date
    var timestamp: Date
    var subType: TrainingSubType
    var trainingData: [TrainingData]
    var training: Training
    
    init(withTraining tr: Training) {
        userId = tr.userId
        id = tr.id
        status = tr.status
        trainingMethod = tr.trainingMethod
        trainingCounter = tr.trainingCounter
        plannedNumberOfWorkouts = tr.plannedNumberOfWorkouts
        createDate = tr.createDate
        timestamp = tr.timestamp
        subType = tr.subType
        trainingData = tr.trainingData
        self.training = tr
    }
}

//MARK: - TrainingViewModel Main
struct TrainingViewModel {
    private var _currentTraining: EditTraining!
    private var _currentTrainingData: TrainingData!
}

//MARK: - TrainingViewModelProtocol
extension TrainingViewModel: TrainingViewModelProtocol {
    var allTrainings: [Training] {
        Service.trainings.sorted { $0.timestamp > $1.timestamp }
    }
    
    subscript(index: Int) -> Training? {
        if index >= allTrainings.count {return nil}
        return allTrainings[index]
    }
    
    mutating func refreshCurrentTraining() {
        let id = _currentTraining.id
        if let training = Service.trainings.first(where: { $0.id == id }) {
            _currentTraining = .init(withTraining: training)
        }
    }
    
    mutating func setCurrentTraining(_ training: Training) {
        _currentTraining = .init(withTraining: training)
        _currentTrainingData = _currentTraining.training.trainingData.first
    }
}

//MARK: - TrainingViewModelRunProtocol
extension TrainingViewModel: TrainingViewModelRunProtocol {
    var currentTraining: Training { _currentTraining.training }
    var currentTrainingData: TrainingData { _currentTrainingData }
    
    func addSerie() {
        
    }
    
    func nextExercise() {
        
    }
    
    func previousExercise() {
        
    }
    
    func saveData() {
        
    }
    
    func finishTraining() {
        
    }
    
    
}
