//
//  ProfileController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation
import UIKit

private let reuseIdentifier = "ProfileCell"

protocol ProfileControllerDelegate: AnyObject{
    func handleLogout()
}

class ProfileController: GradientTableViewController{
    //MARK: - Properties
    weak var delegate: ProfileControllerDelegate?
    private var user: User?{
        didSet{
            headerView.user = user
        }
    }
    private lazy var headerView = ProfileHeader(frame: .init(x: 0, y: 0, width: view.frame.width, height: 380))
    private let footerView = ProfileFoter()
    private let viewModel = ProfileViewModel()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        user = viewModel.fetchUser()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        tableView.rowHeight = 64
    }
    
    //MARK: - UI
    func setupUI(){
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.register(ProfileCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.contentInsetAdjustmentBehavior = .never
        
        footerView.frame = .init(x: 0, y: 0, width: view.frame.height, height: 100)
        footerView.delegate = self
        tableView.tableFooterView = footerView
    }
}

//MARK: - tableview
extension ProfileController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ProfileEnum.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ProfileCell
        let viewModel = ProfileEnum(rawValue: indexPath.row)
        cell.viewModel = viewModel
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = ProfileEnum(rawValue: indexPath.row) else {return}
        Logger.log("Handle Action for \(viewModel.description)")
        
        switch(viewModel){
        case .accountInfo:
            showInfo(message: "\("account.info.appVersion".localized) \(Bundle.main.releaseVersionNumber ?? "") \n Build: \(Bundle.main.buildVersionNumber ?? "")", hideAfter: 3.0)
        case .settings:
            let vc = RegisterUserController()
            vc.delegate = self
            vc.editMode = true
            present(vc, animated: true)
        }
    }
}

//MARK: - ProfileHeaderDelegate
extension ProfileController: ProfileHeaderDelegate{
    func dissmissController() {
        dismiss(animated: true)
    }
}

//MARK: - ProfileFooterDelegate
extension ProfileController: ProfileFooterDelegate{
    func handleLogout() {
        let alert = UIAlertController(title: nil, message: "login.loggingOut.title".localized, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "login.loggingOut".localized, style: .destructive, handler: { _ in
            self.dismiss(animated: true)
            self.delegate?.handleLogout()
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        present(alert, animated: true)
    }
}

//MARK: - RegisterUserControllerDelegate
extension ProfileController: RegisterUserControllerDelegate{
    func updateUser(_ user: User) {
        self.user = user
    }
}
