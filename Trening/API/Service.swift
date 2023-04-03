//
//  Service.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation
import UIKit

struct RegistrationCredentials: RegistrationCredentialsProtocol{
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage
}

struct TrainingSchemeCredentials: TrainingSchemeCredentialsProtocol{
    var trainingMethod: TrainingMethod
    var name: String = "trainingScheme.add.name".localized
    var numberOfWorkouts: Int
    var trainingType: TrainingType
    var trainingSchemeData: [TrainingSchemeDataCredentialsProtocol]
    var userId: String
}

struct TrainingSchemeDataCredentials: TrainingSchemeDataCredentialsProtocol{
    var trainingSchemeId: String
    var exercise: Exercise
    var numberOfSeries: Int
    var weight: Double
    var addWeight: Double
//    var exerciseOrder: Int
}


struct Service: UserApiProtocol{
    //MARK: - Properties
    static var users: [User]{
        get{ UserDefaults.users }
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
        UserDefaults.users.append(usr)
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
                UserDefaults.users[idx] = usr
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
                    UserDefaults.users[i] = usr
                    Logger.log("User: \(usr) Logged in")
                }
                else if usr.isLoggedIn == true{
                    usr.isLoggedIn = false
                    UserDefaults.users[i] = usr
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
        UserDefaults.users[idx] = usr
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
    }
    
    static func createExercise(name: String, user: User, completion: @escaping (ExerciseOperationError?, Exercise?) -> Void){
        if let _ = exercises.first(where: { $0.name == name && $0.userId == user.userId }){
            Logger.error("Exercise: \(name) already exist")
            completion(.alreadyExist, nil)
            return
        }
        let ex = Exercise(name: name, userId: user.userId)
        UserDefaults.exercises.append(ex)
        Logger.log("New Exercise created \(ex)")
        completion(nil, ex)
    }
    
//    static func fetchExercises(_ completion: @escaping ([Exercise]) -> Void){
//        completion(exercises)
//    }
    
    static func removeExercise(_ exercise: Exercise, completion: @escaping (ExerciseOperationError?) -> Void) {
        if let idx = exercises.firstIndex(where: { $0.id == exercise.id }){
            UserDefaults.exercises.remove(at: idx)
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
            UserDefaults.exercises[idx] = exercise
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
    static var trainingSchemes: [TrainingScheme]{
        UserDefaults.trainingSchemes
    }
    
    static func createTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingScheme?) -> Void) {
        if let _ = trainingSchemes.first(where: { $0.name == credentials.name && $0.userId == credentials.userId }){
            Logger.error("Training scheme: \(credentials.name) already exist")
            completion(.alreadyExist, nil)
            return
        }
        
        var tr = TrainingScheme(trainingMethod: credentials.trainingMethod, name: credentials.name, numberOfWorkouts: credentials.numberOfWorkouts, trainingType: credentials.trainingType, userId: credentials.userId, trainingSchemeData: [TrainingSchemeData]())
        
        var trData = [TrainingSchemeData]()
        var counter = 0
        credentials.trainingSchemeData.forEach { dataCedentials in
            trData.append(TrainingSchemeData(trainingSchemeId: tr.id, exercise: dataCedentials.exercise, numberOfSeries: dataCedentials.numberOfSeries, weight: dataCedentials.weight, addWeight: dataCedentials.addWeight, exerciseOrder: counter))
            counter += 1
        }
        tr.trainingSchemeData = trData
        
        UserDefaults.trainingSchemes.append(tr)
        Logger.log("New Training scheme created \(tr)")
        completion(nil, tr)
    }
    
    static func updateTrainingScheme(_ scheme: TrainingScheme, completion: @escaping (TrainingSchemeError?) -> Void) {
        if let idx = trainingSchemes.firstIndex(where: { $0.id == scheme.id }){
            UserDefaults.trainingSchemes[idx] = scheme
            Logger.log("Training scheme \(scheme) was updated")
            completion(nil)
        }
        else{
            Logger.error("Cannot edit Training scheme because it doesn't exist. \(scheme)")
            completion(.cannotFind)
        }
    }
    
    static func removeTrainingScheme(_ scheme: TrainingScheme, completion: @escaping (TrainingSchemeError?) -> Void) {
        if let idx = trainingSchemes.firstIndex(where: { $0.id == scheme.id }){
            UserDefaults.trainingSchemes.remove(at: idx)
            Logger.log("Training scheme \(scheme) was removed")
            completion(nil)
        }
        else{
            Logger.error("Cannot remove Training scheme because it doesn't exist. \(scheme)")
            completion(.cannotFind)
        }
    }
    
    static func createTrainingSchemeData(_ credentials: TrainingSchemeDataCredentialsProtocol, completion: @escaping (TrainingSchemeError?, TrainingSchemeData?) -> Void) {
        if let schemeIdx = trainingSchemes.firstIndex(where: { $0.id == credentials.trainingSchemeId }){
            let counter = UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData.count
            let data = TrainingSchemeData(trainingSchemeId: credentials.trainingSchemeId, exercise: credentials.exercise, numberOfSeries: credentials.numberOfSeries, weight: credentials.weight, addWeight: credentials.addWeight, exerciseOrder: counter)
            UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData.append(data)
            Logger.log("Training scheme data \(data) created")
            completion(nil, data)
        }
        else{
            Logger.error("Cannot create scheme training data because the Training scheme \(credentials.trainingSchemeId) doesn't exist")
            completion(.cannotFind, nil)
        }
    }
    
    static func updateTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void) {
        if let schemeIdx = trainingSchemes.firstIndex(where: { $0.id == data.trainingSchemeId }){
            if let SchemeDataIdx = trainingSchemes[schemeIdx].trainingSchemeData.firstIndex(where: { $0.id == data.id }){
                UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData[SchemeDataIdx] = data
                Logger.log("Training scheme data \(data) updated")
                completion(nil)
            }
            else{
                Logger.error("Cannot find Training Scheme data: \(data) to update")
                completion(.cannotFindData)
            }
        }
        else{
            Logger.error("Cannot update Training Scheme data: \(data) because the training Scheme doesn't exist")
            completion(.cannotFind)
        }
    }
    
    static func removeTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping (TrainingSchemeError?) -> Void) {
        if let schemeIdx = trainingSchemes.firstIndex(where: { $0.id == data.trainingSchemeId }){
            if let SchemeDataIdx = trainingSchemes[schemeIdx].trainingSchemeData.firstIndex(where: { $0.id == data.id }){
                UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData.remove(at: SchemeDataIdx)
                Logger.log("Training scheme data \(data) removed")
                completion(nil)
            }
            else{
                Logger.error("Cannot find Training Scheme data: \(data) to remove")
                completion(.cannotFindData)
            }
        }
        else{
            Logger.error("Cannot remove Training Scheme data: \(data) because the training Scheme doesn't exist")
            completion(.cannotFind)
        }
    }
}

//MARK: - TrainingsProtocol
extension Service: TrainingsApiProtocol{
    static var trainings: [Training]{
        get{ UserDefaults.trainings }
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
