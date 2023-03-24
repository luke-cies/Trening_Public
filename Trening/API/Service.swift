//
//  Service.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation
import UIKit

enum UserOperationError: Error{
    case alreadyExist//create
    case cannotFind//update
}

enum ExerciseOperationError: Error{
    case alreadyExist
    case cannotFind
    
    var description: String{
        switch(self){
        case .alreadyExist:
            return "exercise.alert.error.alreadyExist.message".localized
        case .cannotFind:
            return "exercise.alert.error.cannotFind.message".localized
        }
    }
}

enum TrainingSchemeError: Error{
    
}

protocol RegistrationCredentialsProtocol{
    var email: String {get set}
    var password: String {get set}
    var firstName: String {get set}
    var lastName: String {get set}
    var profileImage: UIImage {get set}
}

protocol TrainingSchemeCredentialsProtocol{
    var method: TrainingMethod {get set}
    var name: String {get set}
    var numberOfWorkouts: Int {get set}
    var trainingType: TrainingType {get set}
    var trainingSchemeData: TrainingSchemeData {get set}
}

protocol UserApiProtocol{
    static var users: [User] {get set}
//    static func fetchUsers(completion: @escaping ([User]) -> Void)
//    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void)
    static func createUser(credentials: RegistrationCredentialsProtocol, completion: @escaping (UserOperationError?, User?) -> Void)
    static func updateUser(_ user: User, completion: @escaping (UserOperationError?, User) -> Void)
    static func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void)
    static func logoutCurrentUser(completion: @escaping (Bool) -> Void)
}

protocol ExerciseApiProtocol{
    static var exercises: [Exercise] {get set}
    static func createExercise(name: String, user: User, completion: @escaping (ExerciseOperationError?, Exercise?) -> Void)
//    static func fetchExercises(_ completion: @escaping ([Exercise]) -> Void)
    static func removeExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void)
    static func updateExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void)
}

protocol TrainingSchemesApiProtocol{
    static var trainingSchemes: [TrainingScheme] {get set}
    static func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingScheme?) -> Void)
    
}

protocol TrainingsApiProtocol{
    static var trainings: [Training] {get set}
}

struct RegistrationCredentials: RegistrationCredentialsProtocol{
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage
}

struct TrainingSchemeCredentials: TrainingSchemeCredentialsProtocol{
    var method: TrainingMethod
    var name: String
    var numberOfWorkouts: Int
    var trainingType: TrainingType
    var trainingSchemeData: TrainingSchemeData
}

struct Service: UserApiProtocol{
    //MARK: - Properties
    static var users: [User]{
        get{ UserDefaults.users }
        set{ UserDefaults.users = newValue }
    }
    
//    static func fetchUsers(completion: @escaping ([User]) -> Void) {
//        completion(users)
//    }
//
//    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void) {
//        let usr = users.first { $0.userId == uid }
//        completion(usr)
//    }
    
    static func createUser(credentials: RegistrationCredentialsProtocol, completion: @escaping (UserOperationError?, User?) -> Void) {
        if let _ = users.first(where: { $0.email == credentials.email }){
            Logger.error("User with email: \(credentials.email) already exist")
            completion(.alreadyExist, nil)
            return
        }
        let avatarPath = Service.saveAvatarImage(img: credentials.profileImage)
        let codedPass = credentials.password.encode()
        let usr = User(email: credentials.email, firstName: credentials.firstName, lastName: credentials.lastName, password: codedPass, avatarFileName: avatarPath.name)
        users.append(usr)
        Logger.log("New user created: \(usr)")
        completion(nil, usr)
    }
    
    static func updateUser(_ user: User, completion: @escaping (UserOperationError?, User) -> Void) {
        if let idx = users.firstIndex(where: { $0.userId == user.userId }){
            Service.removeAvatarImage(user.avatarFileName) { result in
                let avatarPath = Service.saveAvatarImage(img: user.getAvatarDataImage())
                let codedPass = user.passwordChanged ? user.password.encode() : user.password
                var usr = user
                usr.avatarFileName = avatarPath.name
                usr.password = codedPass
                usr.passwordChanged = false
                users[idx] = usr
                Logger.log("User \(user) updated to \(usr)")
                completion(nil, usr)
            }
        }
        else{
            completion(.cannotFind, user)
        }
    }
    
    static func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        let idx = users.firstIndex { $0.email == email && $0.password == password }//Compare hashed password only
        if let idx = idx {
            for i in 0...(users.count - 1){
                var usr = users[i]
                if i == idx{
                    usr.isLoggedIn = true
                    users[i] = usr
                    Logger.log("User: \(usr) Logged in")
                }
                else if usr.isLoggedIn == true{
                    usr.isLoggedIn = false
                    users[i] = usr
                    Logger.log("User: \(usr) Logged out")
                }
            }
            
            completion(true)
        }
        else{
            completion(false)
        }
    }
    
    static func logoutCurrentUser(completion: @escaping (Bool) -> Void) {
        let currentUserId = Service.loggedInUser()?.userId
        guard let idx = users.firstIndex(where: { $0.userId == currentUserId }) else {
            completion(false)
            Logger.error("Cannot Logout currentUser. No user logged in")
            return
        }
        var usr = users[idx]
        usr.isLoggedIn = false
        Service.users[idx] = usr
        completion(true)
        Logger.log("Current user: \(usr) Logged out")
    }
    
    static func loggedInUser() -> User? {
        if let usr = users.first(where: { $0.isLoggedIn == true }){
            return usr
        }
        
        return nil
    }
    
    //MARK: - Private
    private static func saveAvatarImage(img: UIImage?) -> (success: Bool, name: String){
        guard let img = img, let data = img.pngData() else { return (success: false, name: "") }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return (success: false, name: "")
        }
        do {
            let name = UUID().uuidString + ".png"
            let dirPath = directory.appendingPathComponent(name)!
            try data.write(to: dirPath)
            Logger.log("Avatar image saved with name: \(name)")
            return (success: true, name: name)
        } catch {
            Logger.error("saveAvatarImage error: \(error.localizedDescription)")
            return (success: false, name: "")
        }
    }
    
    private static func removeAvatarImage(_ name: String, completion: @escaping (Bool) -> Void){
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completion(false)
            return
        }
        if let fileURL = directory.appendingPathComponent(name){
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(atPath: fileURL.path)
                    Logger.log("Delete Avatar image \(name)")
                    completion(true)
                }
                catch _ {
                    Logger.error("Cannot delete avata image: \(name)")
                    completion(false)
                }
            }
        }
    }
}

//MARK: - ExerciseProtocol
extension Service: ExerciseApiProtocol{
    static var exercises: [Exercise]{
        get{ UserDefaults.exercises }
        set{ UserDefaults.exercises = newValue }
    }
    
    static func createExercise(name: String, user: User, completion: @escaping (ExerciseOperationError?, Exercise?) -> Void){
        if let _ = exercises.first(where: { $0.name == name && $0.userId == user.userId }){
            Logger.error("Exercise: \(name) already exist")
            completion(.alreadyExist, nil)
            return
        }
        let ex = Exercise(name: name, userId: user.userId)
        exercises.append(ex)
        Logger.log("New Exercise created \(ex)")
        completion(nil, ex)
    }
    
//    static func fetchExercises(_ completion: @escaping ([Exercise]) -> Void){
//        completion(exercises)
//    }
    
    static func removeExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void) {
        if let idx = exercises.firstIndex(where: { $0.id == exercise.id }){
            exercises.remove(at: idx)
            Logger.log("Exercise \(exercise) was removed")
            completion(nil)
        }
        else{
            Logger.error("Cannot remove exercise because it doesn't exist. \(exercise)")
            completion(.cannotFind)
        }
    }
    
    static func updateExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void) {
        if let idx = exercises.firstIndex(where: { $0.id == exercise.id }){
            exercises[idx] = exercise
            Logger.log("Exercise \(exercise) was updated")
            completion(nil)
        }
        else{
            Logger.error("Cannot edit exercise because it doesn't exist. \(exercise)")
            completion(.cannotFind)
        }
    }
}

//MARK: - TrainingSchemesProtocol
extension Service: TrainingSchemesApiProtocol{
    static func addTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingScheme?) -> Void) {
        
    }
    
    static var trainingSchemes: [TrainingScheme]{
        get{ UserDefaults.trainingSchemes }
        set{ UserDefaults.trainingSchemes = newValue }
    }
}

//MARK: - TrainingsProtocol
extension Service: TrainingsApiProtocol{
    static var trainings: [Training]{
        get{ UserDefaults.trainings }
        set{ UserDefaults.trainings = newValue }
    }
}


struct DB: Codable{
    //MARK: - Properties
    var users: [User]
    var exercises: [Exercise]
    var trainingSchemes: [TrainingScheme]
    var trainings: [Training]

    //MARK: - Init
    init(){
        users = [User]()
        exercises = [Exercise]()
        trainingSchemes = [TrainingScheme]()
        trainings = [Training]()
    }
}
