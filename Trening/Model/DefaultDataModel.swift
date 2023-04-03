//
//  DefaultDataModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation
import UIKit

struct DefaultDataModel{
    static func initDefaultUser(){
        if UserDefaults.isFirstRun {
            DefaultDataModel.createDefaultUser()
        }
        
//        if let userId = Service.loggedInUser()?.userId, let ex = Service.exercises.first {
//            var data = [TrainingSchemeDataCredentials(exercise: ex, numberOfSeries: 3, weight: 120, addWeight: 2.5, exerciseOrder: 0)]
//            
//            if let ex2 = Service.exercises.last{
//                data.append(TrainingSchemeDataCredentials(exercise: ex2, numberOfSeries: 2, weight: 100, addWeight: 5.0, exerciseOrder: 1))
//            }
//
//            let c = TrainingSchemeCredentials(method: .FBW, name: "Mój schemat treningu", numberOfWorkouts: 12, trainingType: .scheme, trainingSchemeData: data, userId: userId)
//            Service.createTrainingScheme(c) { err, scheme in
//                print(err)
//                print(scheme)
//            }
//        }
    }
    
    static func initDefaultData(){
        if UserDefaults.isFirstRun {
            DefaultDataModel.createDefaultExercises()
            UserDefaults.isFirstRun = false
        }
    }
    
    //MARK: - User
    private static func createDefaultUser(){
        guard let avatar = UIImage(named: "Login/DefaultAvatar") else {
            Logger.error("Cannot create default avatar. There is no Login/DefaultAvatar in the assets")
            return
        }
        
        let c = RegistrationCredentials(email: "lukic@autograf.pl", password: "qazplm123", firstName: "Łukasz", lastName: "C", profileImage: avatar)
        Service.createUser(credentials: c) { (err, usr) in
            if err != nil{
                Logger.error("Cannot create default user: \(c)")
            }
        }
    }
    
    //MARK: - Exercises
    private static func createDefaultExercises(){
        let ex = ["exercise.name.deadLift".localized, "exercise.name.benchPress".localized, "exercise.name.flyFlints".localized ,"exercise.name.dips".localized, "exercise.name.soldierySqueeze".localized, "exercise.name.pullUps".localized, "exercise.name.squats".localized]
        if let user = Service.loggedInUser(){
            ex.forEach { name in
                Service.createExercise(name: name, user: user) {(err, ex) in}//Don't do anything. Just create it
            }
        }
    }
}
