//
//  HeaderMenuViewAdd.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation
import UIKit

class HeaderMenuViewAdd: UIView{
    //MARK: - Properties
    private var addButton = TButton.create("add".localized)
    private var label: UILabel = UILabel(frame: .zero)
    var addButtonTappedCompletion: (() -> Void)!
    var buttonText: String? = String(){
        didSet{
            addButton.isHidden = buttonText == nil || buttonText == ""
            
            if let buttonText = buttonText{
                addButton.title = buttonText
            }
            else{
                addButton.title = ""
                addButton.isHidden = true
            }
        }
    }
    var title: String? = String(){
        didSet{
            label.text = title
        }
    }
    
    //MARK: - Init
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func create(_ completion: @escaping () -> Void) -> HeaderMenuViewAdd{
        let h = HeaderMenuViewAdd(frame: .zero)
        h.addButtonTappedCompletion = completion
        return h
    }
    
    //MARK: - UI
    private func setupUI(){
        backgroundColor = .clear
        
        let line = UIView()
        line.backgroundColor = .TBlack
        
        label.numberOfLines = 1
        label.font = .boldSystemFont(ofSize: Consts.titleFontSize)
        label.textColor = .TBlackText
        
        let stack = UIStackView(arrangedSubviews: [label, addButton])
        stack.axis = .horizontal
        stack.spacing = 5
        
        addButton.setWidth(width: 90)
        addButton.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        
        addSubviews(line, stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 25, paddingRight: 10)
        line.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingBottom: 15, height: 1)
    }
    
    //MARK: - Event
    @objc private func didTapOnButton(_ sender: TButton){
        addButtonTappedCompletion()
    }
}
