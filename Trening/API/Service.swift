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
    case cannotFind//updae
}

protocol RegistrationCredentialsProtocol{
    var email: String {get set}
    var password: String {get set}
    var firstName: String {get set}
    var lastName: String {get set}
    var profileImage: UIImage {get set}
}

protocol UserAPIProtocol{
    static func fetchUsers(completion: @escaping ([User]) -> Void)
    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void)
    static func createUser(credentials: RegistrationCredentialsProtocol, completion: @escaping (UserOperationError?, User?) -> Void)
    static func updateUser(_ user: User, completion: @escaping (UserOperationError?, User) -> Void)
    static func loginUser(email: String, password: String, completion: @escaping (Bool) -> Void)
    static func logoutCurrentUser(completion: @escaping (Bool) -> Void)
}

struct RegistrationCredentials: RegistrationCredentialsProtocol{
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var profileImage: UIImage
}


struct Service: UserAPIProtocol{
    //MARK: - Properties
    private static var users: [User]{
        get{ UserDefaults.users }
        set{ UserDefaults.users = newValue }
    }
    
    //MARK: - Static Methods
    static func fetchUsers(completion: @escaping ([User]) -> Void) {
        completion(users)
    }
    
    static func fetchUser(withUid uid: String, completion: @escaping (User?) -> Void) {
        let usr = users.first { $0.userId == uid }
        completion(usr)
    }
    
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

struct DB: Codable{
    //MARK: - Properties
    var users: [User]
    var exercises: [Exercise]

    //MARK: - Init
    init(){
        users = [User]()
        exercises = [Exercise]()
    }
}
