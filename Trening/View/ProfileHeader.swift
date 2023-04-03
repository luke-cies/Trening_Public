//
//  ProfileHeader.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation
import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func dissmissController()
}

class ProfileHeader: UIView{
    //MARK: - Properties
    var user: User?{
        didSet{
            populateUserData()
        }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    private lazy var dissmissButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "xmark"), for: .normal)
        b.addTarget(self, action: #selector(handleDissmissal), for: .touchUpInside)
        b.tintColor = .white
        b.imageView?.setDimensions(height: 22, width: 22)
        return b
    }()
    private let profileImageView: UIImageView = {
        let i = UIImageView()
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.layer.borderColor = UIColor.white.cgColor
        i.layer.borderWidth = 4.0
        return i
    }()
    private let fullnameLabel = TLabel(text: String(), font: .systemFont(ofSize: 20), textColor: .white, textAlignment: .center)
    
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: UI
    func configureUI(){
        profileImageView.setDimensions(height: 200, width: 200)
        profileImageView.layer.cornerRadius = 200/2
        
        addSubviews(profileImageView)
        profileImageView.centerX(inView: self)
        profileImageView.anchor(top: topAnchor, paddingTop: 96)
        
        let stack = UIStackView(arrangedSubviews: [fullnameLabel])
        stack.axis = .vertical
        stack.spacing = 4
        
        addSubviews(stack)
        stack.centerX(inView: self)
        stack.anchor(top: profileImageView.bottomAnchor, paddingTop: 16)
        
        addSubviews(dissmissButton)
        dissmissButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44, paddingLeft: 12, width: 48, height: 48)
    }
    
    //MARK: - Private
    func populateUserData(){
        guard let user = user else {return}
        
        fullnameLabel.text = user.fullName
        profileImageView.image = user.getAvatarImage()
    }
    
    //MARK: - Events
    @objc func handleDissmissal(){
        delegate?.dissmissController()
    }
}
