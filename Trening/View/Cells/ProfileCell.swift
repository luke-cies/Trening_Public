//
//  ProfileCell.swift
//  FireApp
//
//  Created by Łukasz Cieślik on 23/11/2022.
//

import UIKit


class ProfileCell: UITableViewCell{
    //MARK: - Properties
    var viewModel: ProfileEnum?{
        didSet{
            configure()
        }
    }
    private lazy var iconView: UIView = {
        let v = UIView()
        v.addSubview(iconImage)
        iconImage.centerX(inView: v)
        iconImage.centerY(inView: v)
        v.backgroundColor = .TDarkBlue
        v.setDimensions(height: 40, width: 40)
        v.layer.cornerRadius = 40/2
        return v
    }()
    private let iconImage: UIImageView = {
        let i = UIImageView()
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        i.tintColor = .white
        i.setDimensions(height: 28, width: 28)
        return i
    }()
    private let titleLabel = TLabel(text: String(), font: .systemFont(ofSize: 16), textColor: .TBlackText)
    
    //MARK:  - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let stack = UIStackView(arrangedSubviews: [iconView, titleLabel])
        stack.spacing = 8
        stack.axis = .horizontal
        
        addSubview(stack)
        stack.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 12)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    func configure(){
        guard let viewModel = viewModel else {return}
        
        iconImage.image = UIImage(systemName: viewModel.iconImageName)
        titleLabel.text = viewModel.description
    }
}
