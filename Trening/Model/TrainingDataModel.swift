//
//  TrainingDataModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 09/03/2023.
//

import Foundation
import UIKit

enum TrainingMethod: String, Equatable, CaseIterable, Codable{
    case HST
    case FBW
    
    var value: Int{
        switch(self){
        case .HST: return 0
        case .FBW: return 1
        }
    }
    
    static func create(value: Int) -> TrainingMethod{
        switch(value){
        case 0: return TrainingMethod(rawValue: "HST")!
        case 1: return TrainingMethod(rawValue: "FBW")!
        default: return TrainingMethod(rawValue: "FBW")!
        }
    }
}

enum TrainingType: Int, Codable{
    case scheme
    case plan
}

enum TrainingStatus: Int, Equatable, CaseIterable, Codable{
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

enum TrainingSubType: Int, Equatable, CaseIterable, Codable{
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

struct User: Codable{
    var userId: String = UUID().uuidString
    var email: String
    var firstName: String
    var lastName: String
    var password: String//#####
    var passwordChanged: Bool = false
    var isRemoved: Bool = false
    var avatarFileName: String
    var avatarData: Data?
    var isLoggedIn: Bool = false
    
    //Read Only
    var fullName: String{
        "\(firstName) \(lastName)"
    }
    
    //Methods
    func getAvatarImage() -> UIImage?{
        guard let avatarPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(avatarFileName) else { return nil }
        do{
            let data = try Data(contentsOf: avatarPath)
            return UIImage(data: data)
        }
        catch{
            Logger.error("Cannot load image from path: \(avatarPath)")
        }
        return nil
    }
    
    mutating func setAvatarImage(_ image: UIImage){
        avatarData = image.pngData()
    }
    
    ///Gets avatar image from AvatarData property
    func getAvatarDataImage() -> UIImage?{
        guard let avatarData = avatarData else { return nil }
        return UIImage(data: avatarData)
    }
}

struct Exercise: Codable{
    var id: String = UUID().uuidString
    var name: String
    let userId: String//creator
}

protocol TrainingSchemeProtocol{
    var id: String {get set}
    var trainingMethod: TrainingMethod {get set}
    var name: String {get set}
    var numberOfWorkouts: Int {get set}
    var trainingType: TrainingType {get set}
    var userId: String {get set}//creator
    var trainingSchemeData: [TrainingSchemeData] {get set}
    
    static func numberOfWorkoutsDescription(_ numberOfWorkouts: Int) -> String
}

struct TrainingScheme: Codable, TrainingSchemeProtocol{
    var id: String = UUID().uuidString
    var trainingMethod: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    var trainingType: TrainingType//scheme, plan
    var userId: String//creator
    var trainingSchemeData: [TrainingSchemeData]
    
    static func numberOfWorkoutsDescription(_ numberOfWorkouts: Int) -> String{
        var desc: String = ""
        switch(numberOfWorkouts){
        case 1: desc = "trainingScheme.numberOfTrainingsDescription.1".localized
        case 2...4: desc = "trainingScheme.numberOfTrainingsDescription.2-4".localized
        case 0: desc = "trainingScheme.numberOfTrainingsDescription.0".localized
        default:
            desc = "trainingScheme.numberOfTrainingsDescription.5".localized
        }
        
        return "\(numberOfWorkouts) \(desc)"
    }
    
    init(){
        trainingMethod = .HST
        name = String()
        numberOfWorkouts = 0
        trainingType = .scheme
        userId = String()
        trainingSchemeData = [TrainingSchemeData]()
    }
    
    init(trainingMethod: TrainingMethod, name: String, numberOfWorkouts: Int, trainingType: TrainingType, userId: String, trainingSchemeData: [TrainingSchemeData]){
        self.trainingMethod = trainingMethod
        self.name = name
        self.numberOfWorkouts = numberOfWorkouts
        self.trainingType = trainingType
        self.userId = userId
        self.trainingSchemeData = trainingSchemeData
    }
}

struct TrainingSchemeData: Codable{
    var id: String = UUID().uuidString
    var trainingSchemeId: String
    var exercise: Exercise
    var numberOfSeries: Int
    var weight: Double
    var addWeight: Double //Skok ciężaru
    var exerciseOrder: Int
    
    init(){
        trainingSchemeId = String()
        exercise = Exercise(name: String(), userId: String())
        numberOfSeries = 0
        weight = 0.0
        addWeight = 0.0
        exerciseOrder = 0
    }
    
    init(trainingSchemeId: String, exercise: Exercise, numberOfSeries: Int, weight: Double, addWeight: Double, exerciseOrder: Int){
        self.trainingSchemeId = trainingSchemeId
        self.exercise = exercise
        self.numberOfSeries = numberOfSeries
        self.weight = weight
        self.addWeight = addWeight
        self.exerciseOrder = exerciseOrder
    }
}

struct Training: Codable{
    let userId: String//creator
    var id: String = UUID().uuidString
    var status: TrainingStatus = .toDo
    var trainingMethod: TrainingMethod
    let planId: String//TrainingScheme.id
    let trainingCounter: Int
    let timestamp: Date
    var subType: TrainingSubType
    var trainingData: String
}

struct TrainingData: Codable{
    var id: String = UUID().uuidString
    var status: TrainingStatus = .toDo//without InProgress!!
    var exercise: Exercise
    var plannedNumberOfSeries: Int
    var currentSeries: Int
    var plannedWeight: Double
    var weight: Double
}
