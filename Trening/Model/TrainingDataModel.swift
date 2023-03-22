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
    let name: String
    let userId: String//creator
}

struct TrainingScheme: Codable{
    var id: String = UUID().uuidString
    var trainingMethod: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    let trainingType: TrainingType
    let userId: String//creator
    var trainingSchemeData: TrainingSchemeData
}

struct TrainingSchemeData: Codable{
    var id: String = UUID().uuidString
    var exercise: Exercise
    var numberOfSeries: Int
    var weight: Double
    var addWeight: Double //Skok ciężaru
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
