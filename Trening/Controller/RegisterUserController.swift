//
//  RegisterUserController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 20/03/2023.
//

import Foundation
import UIKit

protocol RegisterUserControllerDelegate: AnyObject{
    func updateUser(_ user: User)
}

class RegisterUserController : GradientBaseController{
    //MARK: - Properties
    weak var delegate: RegisterUserControllerDelegate?
    var editMode: Bool = false {
        didSet{
            emailTextField.isEnabled = !editMode
            passwordTextField.isEnabled = !editMode
            changeButton.isHidden = !editMode
            viewModel.isEditMode = editMode
        }
    }
    private let emailTextField: CustomTextField = {
        let e = CustomTextField(placeholder: "login.emailPassword.email.placeholder".localized)
        e.keyboardType = .emailAddress
        return e
    }()
    private let firstNameTextField: CustomTextField = CustomTextField(placeholder: "login.firstName.placeholder".localized)
    private let lastNameTextField: CustomTextField = CustomTextField(placeholder: "login.lastName.placeholder".localized)
    private let passwordTextField: CustomTextField = {
        let tf = CustomTextField(placeholder: "login.emailPassword.password.placeholder".localized)
        tf.isSecureTextEntry = true
        return tf
    }()
    private lazy var emailContainerView: UIView = {
        return InputContainerView(image: UIImage(named: "Login/mail"), textField: emailTextField)
    }()
    private lazy var firstNameContainerView: UIView = {
        return InputContainerView(image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis.rtl"), textField: firstNameTextField)
    }()
    private lazy var lastNameContainerView: UIView = {
        return InputContainerView(image: UIImage(systemName: "rectangle.and.pencil.and.ellipsis"), textField: lastNameTextField)
    }()
    private lazy var passwordContainerView: InputContainerView = {
        let p = InputContainerView(image: UIImage(named: "Login/lock"), textField: passwordTextField)
        p.addSubviews(changeButton)
        changeButton.centerY(inView: p)
        changeButton.anchor(right: p.rightAnchor, paddingRight: 5, width: 50)
        return p
    }()
    private lazy var changeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("login.password.changeButton.title".localized, for: .normal)
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.backgroundColor = .TButtonGray
        button.setTitleColor(.white, for: .normal)
        button.setHeight(height: 25)
        button.addTarget(self, action: #selector(didTapOnChangePasswordButton), for: .touchUpInside)
        return button
    }()
    private lazy var saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("login.saveButton.title".localized, for: .normal)
        b.layer.cornerRadius = 5
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.backgroundColor = .TButtonGrayInactive
        b.setTitleColor(.white, for: .normal)
        b.setHeight(height: 50)
        b.addTarget(self, action: #selector(didTapOnSaveButton), for: .touchUpInside)
        return b
    }()
    private lazy var avatar: AvatarControl = {
        let a = AvatarControl(frame: .zero)
        a.addTarget(self, action: #selector(didTapOnAvatarButton), for: .touchUpInside)
        return a
    }()
    private lazy var dissmissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.addTarget(self, action: #selector(didTapOnDissmissButton), for: .touchUpInside)
        b.tintColor = .white
        b.imageView?.setDimensions(height: 22, width: 22)
        return b
    }()
    private let waitView = WaitView.create()
    private var viewModel: RegisterUserProtocol!
    
    //MARK: init
    init(){
        super.init(nibName: nil, bundle: nil)
        viewModel = RegisterUserViewModel.create()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupData()
        checkFormStatus()
    }
    
    //MARK: - UI
    private func setupUI(){
        let stack = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView, firstNameContainerView, lastNameContainerView, saveButton])
        stack.axis = .vertical
        stack.spacing = 16
        
        view.addSubviews(avatar, stack)
        avatar.centerX(inView: view)
        avatar.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        stack.anchor(top: avatar.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
        
        view.addSubviews(dissmissButton)
        dissmissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, paddingTop: 20, paddingLeft: 12, width: 48, height: 48)
        
        emailTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        firstNameTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textDidChanged), for: .editingChanged)
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        //wait view
        view.addSubviews(waitView)
        waitView.pinToEdges(of: view)
        waitView.isHidden = true
    }
    
    private func setupData(){
        emailTextField.text = viewModel.email
        passwordTextField.text = viewModel.password
        firstNameTextField.text = viewModel.firstName
        lastNameTextField.text = viewModel.lastName
        avatar.image = viewModel.avatarImage
    }
    
    //MARK: - Events
    @objc private func didTapOnSaveButton(){
        waitView.isHidden = false
        viewModel.save {[weak self] (isSuccess, usr) in
            if !isSuccess{
                let desc = (self?.editMode == true) ? "login.updateUser.error".localized : "login.createUser.error".localized
                self?.showError(desc)
            }
            else{
                if let user = usr{
                    self?.delegate?.updateUser(user)
                }
                if self?.editMode == true{
                    self?.dismiss(animated: true)
                }
            }
            self?.waitView.isHidden = true
        }
    }
    
    @objc private func didTapOnAvatarButton(){
        let imagePisckerController = UIImagePickerController()
        imagePisckerController.delegate = self
        present(imagePisckerController, animated: true, completion: nil)
    }
    
    @objc private func didTapOnChangePasswordButton(){
        showTextFieldAlert(message: "login.password.new.alertTitle".localized, okButtonTitle: "ok".localized, cancelButtonTitle: "cancel".localized, placeholder: "login.password.new.placeholder".localized, isSecured: true) { [weak self] text in
            self?.viewModel.password = text
            self?.passwordTextField.text = text
            self?.checkFormStatus()
        }
    }
    
    @objc private func didTapOnDissmissButton(){
        dismiss(animated: true)
    }
    
    @objc func textDidChanged(sender: UITextField){
        if sender == emailTextField{
            viewModel.email = sender.text?.lowercased()
        }
        else if sender == passwordTextField{
            viewModel.password = sender.text
        }
        else if sender == firstNameTextField{
            viewModel.firstName = sender.text
        }
        else if sender == lastNameTextField{
            viewModel.lastName = sender.text
        }
        checkFormStatus()
    }
}

//MARK: - UITextFieldDelegate
extension RegisterUserController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

//MARK: - AuthenticationControllerProtocol
extension RegisterUserController: AuthenticationControllerProtocol{
    func checkFormStatus() {
        if viewModel.formIsValid == nil {
            saveButton.isEnabled = true
            saveButton.backgroundColor = .TButtonGray
        }
        else{
            saveButton.isEnabled = false
            saveButton.backgroundColor = .TButtonGrayInactive
        }
    }
}

//MARK: - UIImagePickerControllerDelegate
extension RegisterUserController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as? UIImage
        avatar.image = image
        viewModel.avatarImage = image
        dismiss(animated: true)
    }
}
