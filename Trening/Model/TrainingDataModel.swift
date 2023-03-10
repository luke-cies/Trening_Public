//
//  TrainingDataModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 09/03/2023.
//

import Foundation

enum TrainingMethod: String{
    case HST
    case FBW
}

enum TrainingType: Int{
    case scheme
    case plan
}

enum TrainingStatus: Int{
    case toDo
    case inProgress
    case done
    case synchronised
    
    var description: String{
        switch(self){
        case .toDo:         return "training.status.todo".localized
        case .inProgress:   return "training.status.inProgress".localized
        case .done:         return "training.status.done".localized
        case .synchronised: return "training.status.synchronised".localized
        }
    }
}

enum TrainingSubType: Int{
    case mass
    case reduction
    case deload
    
    var description: String{
        switch(self){
        case .mass:         return "trainingSubType.mass".localized
        case .reduction:    return "trainingSubType.reduction".localized
        case .deload:       return "trainingSubType.deload".localized
        }
    }
}

struct User{
    let userId: String = UUID().uuidString
    var email: String
    var firstName: String
    var lastName: String
    var isRemoved: Bool = false
    var avatarPath: String
    var avatarFileName: String
    var isLoggedIn: Bool = false
}

struct Exercise{
    let id: String = UUID().uuidString
    let name: String
    let userId: String//creator
}

struct TrainingScheme{
    let id: String = UUID().uuidString
    var trainingMethod: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    let trainingType: TrainingType
    let userId: String//creator
    var trainingSchemeData: TrainingSchemeData
}

struct TrainingSchemeData{
    let id: String = UUID().uuidString
    var exercise: Exercise
    var numberOfSeries: Int
    var weight: Double
    var addWeight: Double //Skok ciężaru
}

struct Training{
    let userId: String//creator
    let id: String = UUID().uuidString
    var status: TrainingStatus = .toDo
    var trainingMethod: TrainingMethod
    let planId: String//TrainingScheme.id
    let trainingCounter: Int
    let timestamp: Date
    var subType: TrainingSubType
    var trainingData: String
}

struct TrainingData{
    let id: String = UUID().uuidString
    var status: TrainingStatus = .toDo//without InProgress!!
    var exercise: Exercise
    var plannedNumberOfSeries: Int
    var currentSeries: Int
    var plannedWeight: Double
    var weight: Double
}
