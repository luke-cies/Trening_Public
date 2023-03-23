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
    private var lbl: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = .boldSystemFont(ofSize: 20)
        l.textColor = .TBlackText
        l.textAlignment = .left
        return l
    }()
    
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
        
        addSubviews(lbl, line)
        lbl.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingLeft: 25)
        line.anchor(top: lbl.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 3, paddingLeft: 20, height: 1)
        
        let stack = UIStackView(arrangedSubviews: components)
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 5
        addSubviews(stack)
        stack.anchor(top: lbl.bottomAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 20)
    }
}
