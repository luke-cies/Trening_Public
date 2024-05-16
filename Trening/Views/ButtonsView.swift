//
//  ButtonsView.swift
//  Trening
//
//  Created by Łukasz Cieślik on 07/05/2024.
//

import Foundation
import UIKit

class ButtonsView: UIView {
    //MARK: - Properties
    var data: [ButtonData]? = [ButtonData]() { didSet { setupButtons() } }
    var buttonTapActionCompletion: ((Int) -> Void)? //Int: Button Tag
    var buttonsOnTheLeft: Bool = false { didSet { setupButtons() } }
    private var buttonsStack = UIStackView(spacing: 10, subviews: [UIView]())
    
    //MARK: - Init
    init(data: [ButtonData]? = nil) {
        super.init(frame: .zero)
        self.data = data
        
        setupButtons()
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func setupButtons() {
        if let data = data {
            var buttons = [UIView]()
            var counter: Int = 0
            
            data.forEach { (t: ButtonData) in
                let b = TButton.create(t.title)
                b.tag = counter
                b.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
                b.isEnabled = t.isEnabled
                b.widthAnchor.constraint(greaterThanOrEqualToConstant: 70).isActive = true
                buttons.append(b)
                counter += 1
            }
            
            if buttons.count > 0 {
                let stackViews = buttonsStack.arrangedSubviews
                stackViews.forEach { buttonsStack.removeArrangedSubview($0) }
                
                if !buttonsOnTheLeft { buttonsStack.addArrangedSubview(UIView())  }
                buttons.forEach { buttonsStack.addArrangedSubview($0) }
                if buttonsOnTheLeft { buttonsStack.addArrangedSubview(UIView()) }
            }
        }
    }
    
    //MARK: - Events
    @objc private func didTapOnButton(_ sender: UIButton) {
        buttonTapActionCompletion?(sender.tag)
    }
    
    //MARK: - UI
    private func setupUI() {
        addSubviews(buttonsStack)
        buttonsStack.pinToEdges(of: self)
        
        backgroundColor = .clear
        
        setHeight(height: Consts.buttonHeight)
    }
}


struct ButtonData {
    var title: String
    var isEnabled: Bool = true
}
