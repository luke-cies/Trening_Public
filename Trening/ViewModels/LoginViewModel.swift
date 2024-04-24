//
//  LoginViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 13/03/2023.
//

import Foundation

protocol AuthenicationProtocol{
    var formIsValid: String? { get }//Error String
}

protocol LoginViewModelProtocol: AuthenicationProtocol{
    var users: [User] {get}
    var email: String? {get set}
    var password: String? {get set}
    func loginUser(_ completion: @escaping (Bool) -> Void)
    mutating func loginUser(_ user: User, completion: @escaping (Bool) -> Void)
}

struct LoginViewModel: LoginViewModelProtocol{
    //MARK: - Properties
    var users: [User]{
        Service.users
    }
    var email: String?
    var password: String?
    
    //MARK: - Public
    func loginUser(_ completion: @escaping (Bool) -> Void){
        guard let email = email, let password = password else {
            completion(false)
            return
        }
        let hashedPass = password.encode()
        login(email: email, password: hashedPass, completion: completion)
    }
    
    mutating func loginUser(_ user: User, completion: @escaping (Bool) -> Void){
        email = user.email
        password = user.password
        
        guard let email = email, let password = password else {
            completion(false)
            return
        }
        login(email: email, password: password, completion: completion)
    }
    
    //MARK: - Private
    private func login(email: String, password: String, completion: @escaping (Bool) -> Void){
        Service.loginUser(email: email, password: password, completion: completion)
    }
}

//MARK: - AuthenicationProtocol
extension LoginViewModel: AuthenicationProtocol{
    var formIsValid: String? {
        guard let email = email, let password = password else{ return "login.emailPassword.incorrect".localized }
        
        if password.count < 5{ return "login.emailPassword.passwordTooShort".localized }
        
        if email.isEmail == false{
            return "login.emailPassword.notAnEmail".localized
        }
        
        return nil
    }
}
