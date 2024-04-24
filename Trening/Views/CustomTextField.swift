//
//  CustomTextField.swift
//  Trening
//
//  Created by Łukasz Cieślik on 13/03/2023.
//

import UIKit

class CustomTextField: UITextField{
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(placeholder: String, textColor: UIColor = .TBlackText){
        super.init(frame: .zero)
        
        borderStyle = .none
        font = UIFont.systemFont(ofSize: 16)
        self.textColor = textColor
        keyboardAppearance = .default
        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
    }
}
