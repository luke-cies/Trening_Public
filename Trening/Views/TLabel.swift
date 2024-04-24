//
//  TLabel.swift
//  Trening
//
//  Created by Łukasz Cieślik on 28/03/2023.
//

import Foundation
import UIKit


class TLabel: UILabel{
    init(text: String, font: UIFont, textColor color: UIColor, textAlignment alignment: NSTextAlignment = .left){
        super.init(frame: .zero)
        
        self.font = font
        numberOfLines = 0
        lineBreakMode = .byWordWrapping
        minimumScaleFactor = 0.7
        textColor = color
        textAlignment = alignment
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
