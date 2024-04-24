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
    private lazy var exercisesButton: TButton = {
        let b = TButton.create("menu.button.exercise".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    private lazy var schemesButton: TButton = {
        let b = TButton.create("menu.button.schemes".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    private lazy var trainingButton: TButton = {
        let b = TButton.create("menu.button.training".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    private lazy var planButton: TButton = {
        let b = TButton.create("menu.button.plan".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    private lazy var historyButton: TButton = {
        let b = TButton.create("menu.button.history".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    private lazy var maxButton: TButton = {
        let b = TButton.create("menu.button.max".localized, fontSize: Consts.mainMenuButtonFontSize)
        b.addTarget(self, action: #selector(didTapOnMenuButton), for: .touchUpInside)
        return b
    }()
    
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
        navigationItem.leftBarButtonItem?.tintColor = .TBlack
        
        let settings = MenuComponent(label: "menu.segment.title.settings".localized, components: [exercisesButton, schemesButton])
        let training = MenuComponent(label: "menu.segment.title.training".localized, components: [trainingButton, planButton, historyButton])
        let results = MenuComponent(label: "menu.segment.title.result".localized, components: [maxButton])
        let emptyView = UIView()
        
        let stack = UIStackView(axis: .vertical, spacing: 40, subviews: [settings, training, results, emptyView])        
        view.addSubviews(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 50, paddingRight: 30)
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
        Logger.log("Login screen presented")
    }
    
    //MARK: - Events
    @objc private func showProfile(){
        let vc = ProfileController(style: .insetGrouped)
        vc.delegate = self
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    @objc private func didTapOnMenuButton(_ sender: TButton){
        var vc: UIViewController!
        if sender == exercisesButton{
            vc = ExerciseController()
        }
        else if sender == schemesButton{
            vc = TreningSchemesController()
        }
        else if sender == historyButton{
            vc = TrainingHistoryController()
        }
        else if sender == planButton{
            vc = PlannedTrainingList()
        }
        else{
            print("Dokończ")//TODO: Dokończ
            return
        }
        navigationController?.pushViewController(vc, animated: true)
        Logger.log("\(vc.description) presented")
    }
}

//MARK: - AuthenticationDelegate
extension MainMenuController: AuthenticationDelegate{
    func authenticationComplete() {
        viewModel.loadDefaultData()
        dismiss(animated: true)
    }
}

//MARK: - ProfileControllerDelegate
extension MainMenuController: ProfileControllerDelegate{
    func handleLogout() {
        logout()
    }
}
