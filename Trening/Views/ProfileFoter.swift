//
//  ProfileFoter.swift
//  FireApp
//
//  Created by Łukasz Cieślik on 29/11/2022.
//

import UIKit

protocol ProfileFooterDelegate: AnyObject{
    func handleLogout()
}

class ProfileFoter: UIView{
    //MARK: - Properties
    private lazy var logoutButon: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("account.info.logOut".localized, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        b.backgroundColor = .TButtonGray
        b.layer.cornerRadius = 5
        b.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        return b
    }()
    weak var delegate: ProfileFooterDelegate?
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addSubview(logoutButon)
        logoutButon.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 32, paddingRight: 32, height: 50)
        logoutButon.centerY(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Events
    @objc private func handleLogout(){
        delegate?.handleLogout()
    }
}
