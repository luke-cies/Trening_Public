//
//  MainMenuController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation
import UIKit

class MainMenuController: GradientBaseController{
    //MARK: - Properties
    private var viewModel: MainMenuViewModelProtocol = MainMenuViewModel()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        authenticateUser()
    }
    
    //MARK: - UI
    private func setupUI(){
        let image = UIImage(systemName: "person.circle.fill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showProfile))
        navigationItem.rightBarButtonItem?.tintColor = .TBlack
    }
    
    //MARK: - API
    private func authenticateUser(){
//        if Auth.auth().currentUser?.uid == nil{
        if Service.loggedInUser() == nil {
            presentLoginScreen()
        }
    }
    
    private func logout(){
        viewModel.logoutUser {[weak self] result in
            self?.presentLoginScreen()
        }
    }
    
    //MARK: - Private
    private func presentLoginScreen(){
        let vc = LoginController()
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    //MARK: - Events
    
    @objc func showProfile(){
        let vc = ProfileController(style: .insetGrouped)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

//MARK: - AuthenticationDelegate
extension MainMenuController: AuthenticationDelegate{
    func authenticationComplete() {
        dismiss(animated: true)
    }
}

//MARK: - ProfileControllerDelegate
extension MainMenuController: ProfileControllerDelegate{
    func handleLogout() {
        logout()
    }
}
