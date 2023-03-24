//
//  ExerciseViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation

protocol ExerciseViewModelProtocol{
    var exercises: [Exercise] {get}
    func createExercise(_ exerciseName: String, completion: @escaping (String?) -> Void)
    func removeExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void)
    func updateExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void)
}

struct ExerciseViewModel: ExerciseViewModelProtocol{
    var exercises: [Exercise]{
        Service.exercises
    }
    
    func createExercise(_ exerciseName: String, completion: @escaping (String?) -> Void) {
        guard let user = Service.loggedInUser() else {
            Logger.error("Cannot create new Exercise - no logged user")
            completion("exercise.alert.error.noUser.message".localized)
            return
        }
        Service.createExercise(name: exerciseName, user: user) { err, exc in
            completion(err?.description)
        }
    }
    
    func removeExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void) {
        Service.removeExercise(exercise) { err in
            completion(err?.description)
        }
    }
    
    func updateExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void) {
        Service.updateExercise(exercise) { err in
            completion(err?.description)
        }
    }
}
