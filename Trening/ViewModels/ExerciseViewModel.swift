//
//  ExerciseViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation

protocol ExerciseViewModelProtocol{
    var searchText: String {get set}
    var exercises: [Exercise] {get}
    func createExercise(_ exerciseName: String, completion: @escaping (String?) -> Void)
    func removeExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void)
    func updateExercise(_ exercise: Exercise, completion: @escaping (String?) -> Void)
    mutating func reloadExercises()
}

struct ExerciseViewModel: ExerciseViewModelProtocol{
    //MARK: - Properties
    var exercises: [Exercise] = [Exercise]()
    var searchText: String = String(){
        didSet{
            reloadExercises()
        }
    }
    
    //MARK: - Init
    init(){
        reloadExercises()
    }
    
    //MARK: - Public
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
    
    mutating func reloadExercises(){
        exercises = [Exercise]()
        if searchText.count > 0{
            Service.exercises.forEach {
                if $0.name.lowercased().contains(searchText.lowercased()){
                    exercises.append($0)
                }
            }
        }
        else{
            exercises = Service.exercises
        }
    }
}
