//
//  ExerciseCell.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation
import UIKit

class ExerciseCell: UITableViewCell{
    //MARK: - Properties
    private let titleLabel = TLabel(text: String(), font: .systemFont(ofSize: 16), textColor: .TBlackText)
    var title: String = String(){
        didSet{
            titleLabel.text = title
        }
    }
    
    //MARK:  - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.spacing = 8
        stack.axis = .horizontal
        
        addSubviews(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
