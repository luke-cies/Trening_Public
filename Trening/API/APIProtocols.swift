//
//  APIProtocols.swift
//  Trening
//
//  Created by Łukasz Cieślik on 29/03/2023.
//

import Foundation
import UIKit

typealias ApiTrainingSchemeCompletion = (TrainingSchemeError?) -> Void
typealias ApiAddTrainingSchemeCompletion = (TrainingSchemeError?, TrainingScheme?) -> Void
typealias ApiAddTrainingDataSchemeCompletion = (TrainingSchemeError?, TrainingSchemeData?) -> Void

typealias ApiTrainingCompletion = (TrainingError?) -> Void
typealias ApiAddTrainingCompletion = (TrainingError?, Training?) -> Void
typealias ApiAddTrainingDataCompletion = (TrainingError?, TrainingData?) -> Void

enum UserOperationError: Error{
    case alreadyExist//create
    case cannotFind//update
}

enum ExerciseOperationError: Error{
    case alreadyExist
    case cannotFind
    
    var description: String{
        switch(self){
        case .alreadyExist: return "exercise.alert.error.alreadyExist.message".localized
        case .cannotFind:   return "exercise.alert.error.cannotFind.message".localized
        }
    }
}

enum TrainingSchemeError: Error{
    case alreadyExist(isScheme: Bool)
    case cannotFind(isScheme: Bool)
    case cannotFindData(isScheme: Bool)
    
    var description: String{
        switch(self){
        case .alreadyExist(let isScheme): return isScheme ? "trainingScheme.alert.error.alreadyExist.message".localized : "plan.alert.error.alreadyExist.message".localized
        case .cannotFind(let isScheme):   return isScheme ? "trainingScheme.alert.error.cannotFind.message".localized : "plan.alert.error.cannotFind.message".localized
        case .cannotFindData(let isScheme): return isScheme ? "trainingScheme.alert.error.cannotFindData.message".localized : "plan.alert.error.cannotFindData.message".localized
        }
    }
}

enum TrainingError: Error{
    case cannotFind
    case cannotFindData
    
    var description: String{
        switch(self){
        case .cannotFind:   return "training.alert.error.cannotFind.message".localized
        case .cannotFindData: return "training.alert.error.cannotFindData.message".localized
        }
    }
}

protocol RegistrationCredentialsProtocol{
    var email: String {get set}
    var password: String {get set}
    var firstName: String {get set}
    var lastName: String {get set}
    var profileImage: UIImage {get set}
}

protocol TrainingSchemeCredentialsProtocol{
    var trainingMethod: TrainingMethod {get set}
    var name: String {get set}
    var numberOfWorkouts: Int {get set}
    var trainingType: TrainingType {get set}
    var subType: TrainingSubType {get set}
    var trainingSchemeData: [TrainingSchemeDataCredentialsProtocol] {get set}
    var userId: String {get set}
}

protocol TrainingSchemeDataCredentialsProtocol{
    var trainingSchemeId: String {get set}
    var exercise: Exercise {get set}
    var numberOfSeries: Int {get set}
    var weight: Double {get set}
    var addWeight: Double {get set}
    var trainingType: TrainingType {get set}
//    var exerciseOrder: Int {get set}
}

protocol TrainingCredentialsProtocol {
    var trainingCounter: Int {get set}
    var plannedNumberOfWorkouts: Int {get set}
    var subType: TrainingSubType {get set}
    var trainingData: [TrainingDataCredentialsProtocol] {get set}
    var trainingMethod: TrainingMethod {get set}
    var planId: String {get set}//TrainingScheme.id
    var userId: String {get set}
}

protocol TrainingDataCredentialsProtocol {
    var trainingId: String {get set}
    var exercise: Exercise {get set}
    var exerciseOrder: Int {get set}
    var plannedNumberOfSeries: Int {get set}
    var plannedWeight: Double {get set}
//    var comment: String {get set}
}

protocol UserApiProtocol{
    static var users: [User] {get}
//    static func fetchUsers(completion: @escaping ([User]) -> Void)
//    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void)
    static func createUser(credentials: RegistrationCredentialsProtocol, completion: @escaping (UserOperationError?, User?) -> Void)
    static func updateUser(_ user: User, completion: @escaping (UserOperationError?, User) -> Void)
    static func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void)
    static func logoutCurrentUser(completion: @escaping (Bool) -> Void)
}

protocol ExerciseApiProtocol{
    static var exercises: [Exercise] {get}
    static func createExercise(name: String, user: User, completion: @escaping (ExerciseOperationError?, Exercise?) -> Void)
//    static func fetchExercises(_ completion: @escaping ([Exercise]) -> Void)
    static func removeExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void)
    static func updateExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void)
}

protocol TrainingSchemesApiProtocol{
    static var trainingSchemes: [TrainingScheme] {get}
    static func createTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping ApiAddTrainingSchemeCompletion)
    static func removeTrainingScheme(_ scheme: TrainingScheme, completion: @escaping ApiTrainingSchemeCompletion)
    static func updateTrainingScheme(_ scheme: TrainingScheme, completion: ApiTrainingSchemeCompletion?)
    
    static func createTrainingSchemeData(_ credentials: TrainingSchemeDataCredentialsProtocol, completion: @escaping ApiAddTrainingDataSchemeCompletion)
    static func removeTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping ApiTrainingSchemeCompletion)
    static func updateTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping ApiTrainingSchemeCompletion)
}

protocol TrainingsApiProtocol{
    static var trainings: [Training] {get}
    static func createTraining(_ credentials: TrainingCredentialsProtocol, completion: @escaping ApiAddTrainingCompletion)
    static func removeTraining(_ training: Training, completion: @escaping ApiTrainingCompletion)
    static func updateTraining(_ training: Training, completion: ApiTrainingCompletion?)
    
    static func createTrainingData(_ credentials: TrainingDataCredentialsProtocol, completion: @escaping ApiAddTrainingDataCompletion)
    static func removeTrainingData(_ data: TrainingData, completion: @escaping ApiTrainingCompletion)
    static func updateTrainingData(_ data: TrainingData, completion: @escaping ApiTrainingCompletion)
}
