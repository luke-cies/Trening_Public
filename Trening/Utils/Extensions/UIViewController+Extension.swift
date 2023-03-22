//
//  UIViewController+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 10/03/2023.
//

import UIKit
import JGProgressHUD

extension UIViewController{
    static let hud = JGProgressHUD(style: .dark)
    
    func showLoader(_ show: Bool, withText text: String? = "loading".localized){
        view.endEditing(true)
        
        if show{
            UIViewController.hud.textLabel.text = text
            showHud(inView: view)
        }
        else{
            UIViewController.hud.dismiss()
        }
    }
    
    func configureNavigationBar(withTitle title: String, prefersLargeTitles: Bool){
        let appearence = UINavigationBarAppearance()
        appearence.configureWithOpaqueBackground()
        appearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearence.backgroundColor = .systemPurple
        
        navigationController?.navigationBar.standardAppearance = appearence
        navigationController?.navigationBar.compactAppearance = appearence
        navigationController?.navigationBar.scrollEdgeAppearance = appearence
        
        navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        navigationItem.title = title
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = true
        
        navigationController?.navigationBar.overrideUserInterfaceStyle = .dark
    }
    
    func showError(_ errorMessage: String) {
        UIViewController.hud.textLabel.text = "error".localized
        UIViewController.hud.detailTextLabel.text = errorMessage
        showHud(inView: view, afterDelay: 2.0, animated: true)
    }
    
    func showInfo(_ title: String? = nil, message: String, hideAfter delay: TimeInterval){
        UIViewController.hud.textLabel.text = title
        UIViewController.hud.detailTextLabel.text = message
        UIViewController.hud.indicatorView = .none
        showHud(inView: view, afterDelay: delay, animated: true)
    }
    
    ///Shows textField Alert
    func showTextFieldAlert(withTitle title: String? = nil, message: String? = nil, okButtonTitle: String? = nil, cancelButtonTitle: String? = nil, placeholder: String? = nil, text: String? = nil, isSecured: Bool = false, completion: @escaping(String) -> Void){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
            textField.isSecureTextEntry = isSecured
        }
        if let cancelButtonTitle = cancelButtonTitle{
            alert.addAction(UIAlertAction(title: cancelButtonTitle, style: .cancel))
        }
        if let okButtonTitle = okButtonTitle{
            alert.addAction(UIAlertAction(title: okButtonTitle, style: .default, handler: { action in
                if let textFields = alert.textFields,
                   let tf = textFields.first,
                   let text = tf.text{
                    completion(text)
                }
                else{
                    completion("")
                }
            }))
        }
        present(alert, animated: true)
    }
    
    //MARK: - Private
    private func showHud(inView hudView: UIView, afterDelay delay: TimeInterval = 0.0, animated: Bool = false){
        UIViewController.hud.delegate = self
        if UIViewController.isHudVisible == true{
            UIViewController.showHudCompletion = {
                UIViewController.hud.show(in: hudView, animated: animated)
                UIViewController.hud.dismiss(afterDelay: delay, animated: animated)
                UIViewController.showHudCompletion = nil
            }
        }
        else{
            UIViewController.hud.show(in: hudView, animated: animated)
            UIViewController.hud.dismiss(afterDelay: delay, animated: animated)
            UIViewController.showHudCompletion = nil
        }
    }
}

extension UIViewController: JGProgressHUDDelegate{
    private static var isHudVisible: Bool = false
    private static var showHudCompletion: (() -> Void)? = nil
    
    public func progressHUD(_ progressHUD: JGProgressHUD, willPresentIn view: UIView) {
        UIViewController.isHudVisible = true
    }
    
    public func progressHUD(_ progressHUD: JGProgressHUD, didDismissFrom view: UIView) {
        UIViewController.isHudVisible = false
        UIViewController.showHudCompletion?()
    }
}
