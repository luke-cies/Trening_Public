//
//  ProfileViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation

enum ProfileEnum: Int, CaseIterable{
    case accountInfo
    case settings
    
    var description: String{
        switch self{
        case .accountInfo: return "account.info".localized
        case .settings: return "account.settings".localized
        }
    }
    
    var iconImageName: String{
        switch self{
        case .accountInfo: return "person.circle"
        case .settings: return "gear"
        }
    }
}

struct ProfileViewModel{
    func fetchUser() -> User?{
        Service.loggedInUser()
    }
}
