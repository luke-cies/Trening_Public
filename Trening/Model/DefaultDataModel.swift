//
//  DefaultDataModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation
import UIKit

struct DefaultDataModel{
    static func initDefaultData(){
        if UserDefaults.isFirstRun {
            DefaultDataModel.createDefaultUser()
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
}
