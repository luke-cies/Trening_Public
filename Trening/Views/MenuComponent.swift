//
//  MenuComponent.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation
import UIKit

class MenuComponent: UIView{
    //MARK: - Properties
    private var lbl = TLabel(text: String(), font: .boldSystemFont(ofSize: 20), textColor: .TBlackText, textAlignment: .left)
    
    //MARK: - Init
    init(label: String, components: [UIControl]){
        super.init(frame: .zero)
        lbl.text = label
        setupUI(components)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    private func setupUI(_ components: [UIControl]){
        backgroundColor = .clear
        
        let line = UIView()
        line.backgroundColor = .TLineGray
        
        lbl.textAlignment = .left
        addSubviews(lbl, line)
        lbl.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 25)
        line.anchor(top: lbl.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 3, paddingLeft: 20, height: 1)
        
        let stack = UIStackView(axis: .vertical, distribution: .fillEqually, spacing: 5, subviews: components)
        addSubviews(stack)
        stack.anchor(top: lbl.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20)
    }
}
