//
//  AvatarControl.swift
//  Trening
//
//  Created by Łukasz Cieślik on 21/03/2023.
//

import Foundation
import UIKit

class AvatarControl: UIControl{
    //MARK: - Properties
    private var imageView: UIImageView = {
        let i = UIImageView()
        i.clipsToBounds = true
        i.contentMode = .scaleAspectFill
        return i
    }()
    var image: UIImage? {
        didSet{
            imageView.image = image
        }
    }
    
    //MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        
        imageView.image = UIImage(named: "Login/DefaultAvatar")//default one
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    
    //MARK: - UI
    private func setupUI(){
        setDimensions(height: 100, width: 100)
        
        addSubviews(imageView)
        imageView.pinToEdges(of: self)
        
        layer.cornerRadius = 100/2
        layer.masksToBounds = true

        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 3.0
    }
}
