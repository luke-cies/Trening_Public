//
//  GradientBaseController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 20/03/2023.
//

import Foundation
import UIKit

private class GradientClass{
    //MARK: - Static
    static func configureGradient(in view: UIView, currentGradient: inout CAGradientLayer?){
        if let currentGradient = currentGradient{
            currentGradient.colors = [UIColor.dynamicColor(lightMode: .white, darkMode: .black).cgColor, UIColor.TDarkGray.cgColor, UIColor.dynamicColor(lightMode: .white, darkMode: .black).cgColor]
        }
        else{
            let gradient = CAGradientLayer()
            gradient.colors = [UIColor.dynamicColor(lightMode: .white, darkMode: .black).cgColor, UIColor.TDarkGray.cgColor, UIColor.dynamicColor(lightMode: .white, darkMode: .black).cgColor]
            gradient.locations = [0, 0.5, 1]
            view.layer.addSublayer(gradient)
            gradient.frame = view.frame
            currentGradient = gradient
        }
    }
}

class GradientBaseController: UIViewController{
    //MARK: - Properties
    private var myGradientLayer: CAGradientLayer!
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWentForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
        configureGradient()
    }
    
    //MARK: - Public
    func configureGradient(){
        GradientClass.configureGradient(in: view, currentGradient: &myGradientLayer)
    }

    //MARK: - Events
    @objc func appWentForeground(){
        self.configureGradient()
    }
}

class GradientTableViewController: UITableViewController{
    //MARK: - Properties
    private var myGradientLayer: CAGradientLayer!
    private var tableViewBackground: UIView!
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appWentForeground), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureGradient()
    }
    
    //MARK: - Public
    func configureGradient(){
        if tableViewBackground == nil{
            tableViewBackground = UIView(frame: tableView.bounds)
            tableView.backgroundView = tableViewBackground
        }
        GradientClass.configureGradient(in: tableViewBackground, currentGradient: &myGradientLayer)
    }
    
    //MARK: - Events
    @objc func appWentForeground(){
        self.configureGradient()
    }
}
