//
//  UserDefaults+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation


extension UserDefaults{
    //MARK: - Public
    static var users: [User] {
        get{
            db.users
        }
        set{
            db.users = newValue
        }
    }
    
    static var isFirstRun: Bool {
        get{
            !standard.bool(forKey: Keys.firstRun.rawValue)
        }
        set{
            standard.set(!newValue, forKey: Keys.firstRun.rawValue)
        }
    }
    
    //MARK: - Enum
    enum Keys: String{
        case db
        case firstRun
    }
    
    //MARK: - Private
    private static var db: DB{
        get{
            (try? JSONDecoder().decode(DB.self, from: standard.data(forKey: Keys.db.rawValue) ?? Data())) ?? .init()
        }
        set(value){
            if let data = try? JSONEncoder().encode(value){
                standard.setValue(data, forKey: Keys.db.rawValue)
            }
        }
    }
}
