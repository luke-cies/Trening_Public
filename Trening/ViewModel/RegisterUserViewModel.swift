//
//  RegisterUserViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 21/03/2023.
//

import Foundation
import UIKit

protocol RegisterUserProtocol{
    var isEditMode: Bool {get set}
    var firstName: String? {get set}
    var lastName: String? {get set}
    var email: String? {get set}
    var password: String? {get set}
    var avatarImage: UIImage? {get set}
    var formIsValid: String? {get}
    var currentUser: User? {get}
    static func create() -> RegisterUserProtocol
    mutating func save(completion: @escaping (Bool, User?) -> Void)
}

struct RegisterUserViewModel {
    //MARK: - Properties
    private var _currentUser: User
    private var _isEditMode: Bool = false
    private var _firstName: String?
    private var _lastName: String?
    private var _email: String?
    private var _password: String?
    private var _avatarImage: UIImage?
    
    //MARK: - Init
    private init(_ user: User?){
        if let user = user{
            _currentUser = user
        }
        else{
            _currentUser = User(email: String(), firstName: String(), lastName: String(), password: String(), avatarFileName: String())
        }
        _currentUser.passwordChanged = false
        firstName = _currentUser.firstName
        lastName = _currentUser.lastName
        email = _currentUser.email
        password = _currentUser.password
        avatarImage = _currentUser.getAvatarImage() ?? UIImage(named: "Login/DefaultAvatar")
    }
}

extension RegisterUserViewModel: RegisterUserProtocol{
    var isEditMode: Bool{
        get{ _isEditMode }
        set{ _isEditMode = newValue }
    }
    var firstName: String? {
        get {_firstName}
        set {_firstName = newValue}
    }
    var lastName: String? {
        get {_lastName}
        set {_lastName = newValue}
    }
    var email: String? {
        get {_email}
        set {_email = newValue}
    }
    var password: String? {
        get {_password}
        set {_password = newValue}
    }
    var avatarImage: UIImage? {
        get {_avatarImage}
        set {_avatarImage = newValue}
    }
    var formIsValid: String? {
        guard let email = email, let password = password, let firstName = firstName, let lastName = lastName else{ return "login.error.missingData".localized }
        if password.count < 5{ return "login.emailPassword.passwordTooShort".localized }
        
        if email.isEmail == false{
            return "login.emailPassword.notAnEmail".localized
        }
        
        if firstName.count < 1 { return "login.error.firstName.tooShort".localized }
        if lastName.count < 1 { return "login.error.lastName.tooShort".localized }
        
        return nil
    }
    var currentUser: User?{
        _currentUser
    }
    
    //MARK: - Init
    static func create() -> RegisterUserProtocol{
        let user = Service.loggedInUser()
        return RegisterUserViewModel(user)
    }
    
    //MARK: - Public
    mutating func save(completion: @escaping (Bool, User?) -> Void){
        if formIsValid != nil {
            completion(false, _currentUser)
            Logger.error("Cannot save user. The form is not Valid")
            return
        }
        guard let avatarImage = _avatarImage else {
            completion(false, _currentUser)
            Logger.error("Cannot save user. The form is not Valid")
            return
        }
        
        if isEditMode == true{
            _currentUser.passwordChanged = _currentUser.password != password!
            _currentUser.email = email!
            _currentUser.password = password!
            _currentUser.firstName = firstName!
            _currentUser.lastName = lastName!
            _currentUser.setAvatarImage(avatarImage)
            Service.updateUser(_currentUser) { [self] (err, usr) in
                if err != nil{
                    Logger.error("Cannot update user: \(_currentUser)")
                }
                completion(err == nil, usr)
            }
        }
        else{
            let c = RegistrationCredentials(email: email!, password: password!, firstName: firstName!, lastName: lastName!, profileImage: avatarImage)
            Service.createUser(credentials: c) { (err, user) in
                if err != nil{
                    Logger.error("Cannot create default user: \(c)")
                }
                completion(err == nil, user)
            }
        }
    }
}
