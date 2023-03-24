//
//  AddTrainingSchemeController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 24/03/2023.
//

import Foundation
import UIKit


class AddTrainingSchemeController: GradientBaseController{
    //MARK: - Properties
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI
    private func setupUI(){
        let headerView = HeaderMenuViewAdd.create { [weak self] in
            
        }
        headerView.title = "trainingScheme.title".localized
        headerView.buttonText = "save".localized
        
        view.addSubviews(headerView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor)
    }
    
    //MARK: - Private
    
}
