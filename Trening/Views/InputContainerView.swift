//
//  InputContainerView.swift
//  Trening
//
//  Created by Łukasz Cieślik on 13/03/2023.
//

import UIKit

class InputContainerView: UIView{
    init(image: UIImage?, textField: UITextField){
        super.init(frame: .zero)
        
        setHeight(height: 50)
        let iv = UIImageView()
        iv.image = image
        iv.tintColor = .white
        iv.alpha = 0.87
        
        addSubviews(iv)
        iv.centerY(inView: self)
        iv.anchor(left: self.leftAnchor, paddingLeft: 8)
        iv.setDimensions(height: 24, width: 24)
        
        addSubviews(textField)
        textField.centerY(inView: self)
        textField.anchor(left: iv.rightAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, paddingBottom: -8, paddingRight: 8)
        
        let lineView = UIView()
        lineView.backgroundColor = .white
        addSubviews(lineView)
        lineView.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingLeft: 8, height: 0.75)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
