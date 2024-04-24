//
//  MainMenuViewModel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation

protocol MainMenuViewModelProtocol{
    func logoutUser(completion:  @escaping (Bool) -> Void)
    func loadDefaultData()
}

struct MainMenuViewModel: MainMenuViewModelProtocol{
    //MARK: - Public
    func logoutUser(completion:  @escaping (Bool) -> Void){
        guard let _ = Service.loggedInUser() else {
            completion(false)
            return
        }
        Service.logoutCurrentUser(completion: completion)
    }
    
    func loadDefaultData(){
        DefaultDataModel.initDefaultData()
    }
}
