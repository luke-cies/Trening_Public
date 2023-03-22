//
//  LoginController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import Foundation
import UIKit

protocol AuthenticationControllerProtocol{
    func checkFormStatus()
}

protocol AuthenticationDelegate: AnyObject{
    func authenticationComplete()
}

class LoginController: GradientBaseController{
    //MARK: - Properties
    weak var delegate: AuthenticationDelegate?
    private let iconImage: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "bubble.right")
        iv.tintColor = UIColor.white
        return iv
    }()
    private lazy var emailContainerView: UIView = {
        return InputContainerView(image: UIImage(named: "Login/mail"), textField: emailTextField)
    }()
    private lazy var passwordContainerView: InputContainerView = {
        return InputContainerView(image: UIImage(named: "Login/lock"), textField: passwordTextField)
    }()
    private lazy var loginButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("login.loginButton.title".localized, for: .normal)
        b.layer.cornerRadius = 5
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.backgroundColor = .TButtonGray
        b.setTitleColor(.white, for: .normal)
        b.setHeight(height: 50)
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    private let emailTextField: CustomTextField = {
        let e = CustomTextField(placeholder: "login.emailPassword.email.placeholder".localized)
        e.keyboardType = .emailAddress
        return e
    }()
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "login.emailPassword.password.placeholder".localized)
        tf.isSecureTextEntry = true
        return tf
    }()
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "\("login.register.label".localized)   ",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                     .foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "login.register.signUp".localized, attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                  .foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    private var viewModel: LoginViewModelProtocol = LoginViewModel()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkFormStatus()
    }
    
    //MARK: - UI
    private func setupUI(){
        view.backgroundColor = .TBlack
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, loginButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubviews(iconImage, stack, dontHaveAccountButton)
        
        iconImage.centerX(inView: view)
        iconImage.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 32)
        iconImage.setDimensions(height: 120, width: 120)
        
        stack.anchor(top: iconImage.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 32, paddingLeft: 32, paddingRight: 32)
        
        dontHaveAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 32, paddingRight: 32)
        
        emailTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - Private
    
    //MARK: - Events
    @objc func handleShowSignUp(){
//        let controller = RegistrationController()
//        controller.delegate = delegate
//        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func textDidChanged(sender: UITextField){
        if sender == emailTextField{
            viewModel.email = sender.text?.lowercased()
        }
        else if sender == passwordTextField{
            viewModel.password = sender.text
        }
        checkFormStatus()
    }
    
    @objc func handleLogin(){
        showLoader(true, withText: "login.loggingIn".localized)
        viewModel.loginUser() { result in
            if result == false{
                self.showLoader(false)
                self.showError("login.loginError".localized)
                return
            }
            self.showLoader(false)
            self.delegate?.authenticationComplete()
        }
    }
}

//MARK: - AuthenticationControllerProtocol
extension LoginController: AuthenticationControllerProtocol{
    func checkFormStatus() {
        if viewModel.formIsValid == nil {
            loginButton.isEnabled = true
            loginButton.backgroundColor = .TButtonGray
        }
        else{
            loginButton.isEnabled = false
            loginButton.backgroundColor = .TButtonGrayInactive
        }
    }
}
