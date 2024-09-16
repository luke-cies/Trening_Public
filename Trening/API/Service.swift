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
    var subType: TrainingSubType = .mass
    var trainingSchemeData: [TrainingSchemeDataCredentialsProtocol]
    var userId: String
}

struct TrainingSchemeDataCredentials: TrainingSchemeDataCredentialsProtocol{
    var trainingSchemeId: String
    var exercise: Exercise
    var numberOfSeries: Int
    var weight: Double
    var addWeight: Double
    var trainingType: TrainingType
//    var exerciseOrder: Int
}

struct TrainingCredentials: TrainingCredentialsProtocol {
    var trainingCounter: Int
    var plannedNumberOfWorkouts: Int
    var subType: TrainingSubType
    var trainingData: [TrainingDataCredentialsProtocol]
    var trainingMethod: TrainingMethod
    var planId: String
    var userId: String
    
    struct TrainingDataCredentials: TrainingDataCredentialsProtocol {
        var trainingId: String
        var exercise: Exercise
        var exerciseOrder: Int
        var plannedNumberOfSeries: Int
        var plannedWeight: Double
//        var comment: String
    }
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
        var activeSchemes: [TrainingScheme] = [TrainingScheme]()

        UserDefaults.trainingSchemes.filter{ $0.isRemoved != true }.forEach { scheme in
            activeSchemes.append(scheme)
            let schemeData = scheme.trainingSchemeData.filter({ $0.isRemoved != true })
            if let lastIndex = activeSchemes.firstIndex(where: { $0.id == scheme.id }) {
                activeSchemes[lastIndex].trainingSchemeData = schemeData
            }
        }

        return activeSchemes
    }
    
    private static var allTrainingSchemes: [TrainingScheme] {
        UserDefaults.trainingSchemes
    }
    
    static func createTrainingScheme(_ credentials: TrainingSchemeCredentialsProtocol, completion: @escaping ApiAddTrainingSchemeCompletion) {
        if let _ = trainingSchemes.first(where: { $0.name == credentials.name && $0.userId == credentials.userId && $0.trainingType == credentials.trainingType && $0.numberOfWorkouts == credentials.numberOfWorkouts && $0.trainingMethod == credentials.trainingMethod }){
            Logger.error("Training scheme: \(credentials.name) already exist")
            completion(.alreadyExist(isScheme: credentials.trainingType == .scheme), nil)
            return
        }
        
        var tr = TrainingScheme(trainingMethod: credentials.trainingMethod, name: credentials.name, numberOfWorkouts: credentials.numberOfWorkouts, trainingType: credentials.trainingType, userId: credentials.userId, trainingSchemeData: [TrainingSchemeData](), subType: credentials.subType)
        
        var trData = [TrainingSchemeData]()
        var counter = 0
        credentials.trainingSchemeData.forEach { dataCedentials in
            trData.append(TrainingSchemeData(trainingSchemeId: tr.id, exercise: dataCedentials.exercise, numberOfSeries: dataCedentials.numberOfSeries, weight: dataCedentials.weight, addWeight: dataCedentials.addWeight, exerciseOrder: counter, trainingType: credentials.trainingType))
            counter += 1
        }
        tr.trainingSchemeData = trData
        
        UserDefaults.trainingSchemes.append(tr)
        Logger.log("New Training scheme created \(tr)")
        completion(nil, tr)
    }
    
    static func updateTrainingScheme(_ scheme: TrainingScheme, completion: ApiTrainingSchemeCompletion?) {
        if let idx = allTrainingSchemes.firstIndex(where: { $0.id == scheme.id }){
            UserDefaults.trainingSchemes[idx] = scheme
            Logger.log("Training scheme \(scheme) was updated")
            completion?(nil)
        }
        else{
            Logger.error("Cannot edit Training scheme because it doesn't exist. \(scheme)")
            completion?(.cannotFind(isScheme: scheme.trainingType == .scheme))
        }
    }
    
    static func removeTrainingScheme(_ scheme: TrainingScheme, completion: @escaping ApiTrainingSchemeCompletion) {
        if let _ = allTrainingSchemes.firstIndex(where: { $0.id == scheme.id }){
//            UserDefaults.trainingSchemes.remove(at: idx)
            Service.updateTrainingScheme(scheme, completion: completion)
            Logger.log("Training scheme \(scheme) was removed")
//            completion(nil)
        }
        else{
            Logger.error("Cannot remove Training scheme because it doesn't exist. \(scheme)")
            completion(.cannotFind(isScheme: scheme.trainingType == .scheme))
        }
    }
    
    static func createTrainingSchemeData(_ credentials: TrainingSchemeDataCredentialsProtocol, completion: @escaping ApiAddTrainingDataSchemeCompletion) {
        if let schemeIdx = allTrainingSchemes.firstIndex(where: { $0.id == credentials.trainingSchemeId }){
            let counter = UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData.count
            let data = TrainingSchemeData(trainingSchemeId: credentials.trainingSchemeId, exercise: credentials.exercise, numberOfSeries: credentials.numberOfSeries, weight: credentials.weight, addWeight: credentials.addWeight, exerciseOrder: counter, trainingType: credentials.trainingType)
            UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData.append(data)
            Logger.log("Training scheme data \(data) created")
            completion(nil, data)
        }
        else{
            Logger.error("Cannot create scheme training data because the Training scheme \(credentials.trainingSchemeId) doesn't exist")
            completion(.cannotFind(isScheme: credentials.trainingType == .scheme), nil)
        }
    }
    
    static func updateTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping ApiTrainingSchemeCompletion) {
        if let schemeIdx = allTrainingSchemes.firstIndex(where: { $0.id == data.trainingSchemeId }){
            if let SchemeDataIdx = allTrainingSchemes[schemeIdx].trainingSchemeData.firstIndex(where: { $0.id == data.id }){
                UserDefaults.trainingSchemes[schemeIdx].trainingSchemeData[SchemeDataIdx] = data
                Logger.log("Training scheme data \(data) updated")
                completion(nil)
            }
            else{
                Logger.error("Cannot find Training Scheme data: \(data) to update")
                completion(.cannotFindData(isScheme: data.trainingType == .scheme))
            }
        }
        else{
            Logger.error("Cannot update Training Scheme data: \(data) because the training Scheme doesn't exist")
            completion(.cannotFind(isScheme: data.trainingType == .scheme))
        }
    }
    
    static func removeTrainingSchemeData(_ data: TrainingSchemeData, completion: @escaping ApiTrainingSchemeCompletion) {
        if let _ = allTrainingSchemes.firstIndex(where: { $0.id == data.trainingSchemeId }){
                Service.updateTrainingSchemeData(data, completion: completion)
        }
        else{
            Logger.error("Cannot remove Training Scheme data: \(data) because the training Scheme doesn't exist")
            completion(.cannotFind(isScheme: data.trainingType == .scheme))
        }
    }
}

//MARK: - TrainingsProtocol
extension Service: TrainingsApiProtocol{
    static var trainings: [Training]{
        var activeTrainings: [Training] = [Training]()
        
        UserDefaults.trainings.filter{ $0.isRemoved != true }.forEach { training in
            activeTrainings.append(training)
            let trainingData = training.trainingData.filter({ $0.isRemoved != true })
            if let lastIndex = activeTrainings.firstIndex(where: { $0.id == training.id }) {
                activeTrainings[lastIndex].trainingData = trainingData
            }
        }

        return activeTrainings
    }
    
    private static var allTrainings: [Training] {
        UserDefaults.trainings
    }
    
    static func createTraining(_ credentials: TrainingCredentialsProtocol, completion: @escaping ApiAddTrainingCompletion) {
        var tr = Training(userId: credentials.userId, trainingMethod: credentials.trainingMethod, planId: credentials.planId, trainingCounter: credentials.trainingCounter, plannedNumberOfWorkouts: credentials.plannedNumberOfWorkouts, createDate: .now, subType: credentials.subType, trainingData: [TrainingData]())
        
        var trData = [TrainingData]()
        var counter = 0
        credentials.trainingData.forEach { dataCedentials in
            trData.append(TrainingData(trainingId: tr.id, exercise: dataCedentials.exercise, exerciseOrder: dataCedentials.exerciseOrder, plannedNumberOfSeries: dataCedentials.plannedNumberOfSeries, plannedWeight: dataCedentials.plannedWeight))
            counter += 1
        }
        tr.trainingData = trData
        
        UserDefaults.trainings.append(tr)
        Logger.log("New Training created \(tr)")
        completion(nil, tr)
    }
    
    static func removeTraining(_ training: Training, completion: @escaping ApiTrainingCompletion) {
        if let _ = allTrainings.firstIndex(where: { $0.id == training.id }){
            Service.updateTraining(training, completion: completion)
            Logger.log("Training scheme \(trainings) was removed")
        }
        else{
            Logger.error("Cannot remove Training because it doesn't exist. \(training)")
            completion(.cannotFind)
        }
    }
    
    static func updateTraining(_ training: Training, completion: ApiTrainingCompletion?) {
        if let idx = allTrainings.firstIndex(where: { $0.id == training.id }){
            UserDefaults.trainings[idx] = training
            Logger.log("Training \(training) was updated")
            completion?(nil)
        }
        else{
            Logger.error("Cannot edit Training because it doesn't exist. \(training)")
            completion?(.cannotFind)
        }
    }
    
    static func createTrainingData(_ credentials: TrainingDataCredentialsProtocol, completion: @escaping ApiAddTrainingDataCompletion) {
        if let trainingIdx = allTrainings.firstIndex(where: { $0.id == credentials.trainingId }){
            let data = TrainingData(trainingId: credentials.trainingId, exercise: credentials.exercise, exerciseOrder: credentials.exerciseOrder, plannedNumberOfSeries: credentials.plannedNumberOfSeries, plannedWeight: credentials.plannedWeight)
//            UserDefaults.trainings[trainingIdx].trainingData.append(data)
            
            var training = allTrainings[trainingIdx]
            training.trainingData.append(data)
            updateTraining(training) { (error: TrainingError?) in
                if let error = error {
                    Logger.log("Training data \(data) NOT created because of error: \(error)")
                    completion(error, nil)
                    return
                }
                
                Logger.log("Training data \(data) created")
                completion(nil, data)
            }
        }
        else{
            Logger.error("Cannot create training data because the Training \(credentials.trainingId) doesn't exist")
            completion(.cannotFind, nil)
        }
    }
    
    static func removeTrainingData(_ data: TrainingData, completion: @escaping ApiTrainingCompletion) {
        if let _ = allTrainings.firstIndex(where: { $0.id == data.trainingId }){
                Service.updateTrainingData(data, completion: completion)
        }
        else{
            Logger.error("Cannot remove Training data: \(data) because the training doesn't exist")
            completion(.cannotFind)
        }
    }
    
    static func updateTrainingData(_ data: TrainingData, completion: @escaping ApiTrainingCompletion) {
        if let trainingIdx = allTrainings.firstIndex(where: { $0.id == data.trainingId }){
            if let dataIdx = allTrainings[trainingIdx].trainingData.firstIndex(where: { $0.id == data.id }){
//                UserDefaults.trainings[trainingIdx].trainingData[dataIdx] = data
                
                var training = allTrainings[trainingIdx]
                training.trainingData[dataIdx] = data
                
                updateTraining(training) { (error: TrainingError?) in
                    if let error = error {
                        Logger.log("Training data \(data) NOT updated because of error: \(error)")
                        completion(error)
                        return
                    }
                    
                    Logger.log("Training data \(data) updated")
                    completion(nil)
                }
            }
            else{
                Logger.error("Cannot find Training data: \(data) to update")
                completion(.cannotFindData)
            }
        }
        else{
            Logger.error("Cannot update Training data: \(data) because the training doesn't exist")
            completion(.cannotFind)
        }
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
