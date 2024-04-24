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
    private lazy var loginButton: TButton = {
        let b = TButton.create("login.loginButton.title".localized, fontSize: 18)
        b.setHeight(height: 50)
        b.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return b
    }()
    private lazy var emailTextField: CustomTextField = {
        let e = CustomTextField(placeholder: "login.emailPassword.email.placeholder".localized)
        e.keyboardType = .emailAddress
        e.delegate = self
        return e
    }()
    private lazy var passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "login.emailPassword.password.placeholder".localized)
        tf.isSecureTextEntry = true
        tf.delegate = self
        return tf
    }()
    private lazy var dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "\("login.register.label".localized)   ",
                                                        attributes: [.font: UIFont.systemFont(ofSize: 16),
                                                                     .foregroundColor: UIColor.TDarkGrayText])
        attributedTitle.append(NSAttributedString(string: "login.register.signUp".localized, attributes: [.font: UIFont.boldSystemFont(ofSize: 16),
                                                                                  .foregroundColor: UIColor.TDarkGrayText]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.setTitleColor(.TButtonGray, for: .normal)
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    }()
    private var registerController: RegisterUserController!
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
        
        let stack = UIStackView(axis: .vertical, spacing: 16, subviews: [emailContainerView, passwordContainerView, loginButton])        
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
    
    //MARK: - Events
    @objc func handleShowSignUp(){
        registerController = RegisterUserController()
        registerController.delegate = self
        registerController.editMode = false
        navigationController?.pushViewController(registerController, animated: true)
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

//MARK: - RegisterUserControllerDelegate
extension LoginController: RegisterUserControllerDelegate{
    func updateUser(_ user: User) {
        showLoader(true, withText: "login.loggingIn".localized)
        viewModel.loginUser(user) { result in
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

//MARK: - UITextFieldDelegate
extension LoginController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
