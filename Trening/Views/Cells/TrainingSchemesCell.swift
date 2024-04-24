//
//  TrainingSchemesCell.swift
//  Trening
//
//  Created by Łukasz Cieślik on 28/03/2023.
//

import Foundation
import UIKit

class TrainingSchemesCell: UITableViewCell{
    //MARK: - Properties
    private let nameLabel = TLabel(text: String(), font: .systemFont(ofSize: 15), textColor: .TBlackText)
    private let typeLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private let numberOfTrainingsLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    var scheme: TrainingScheme?{
        didSet{
            configure()
        }
    }
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let stack = UIStackView(arrangedSubviews: [nameLabel, typeLabel, numberOfTrainingsLabel])
        stack.axis = .horizontal
        stack.spacing = 5
        
        addSubviews(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 3, paddingLeft: 5, paddingBottom: 3, paddingRight: 3)
        typeLabel.setWidth(width: 50)
        numberOfTrainingsLabel.setWidth(width: 100)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func configure(){
        nameLabel.text = scheme?.name
        typeLabel.text = scheme?.trainingMethod.rawValue
        
        if let numberOfWorkouts = scheme?.numberOfWorkouts{
            numberOfTrainingsLabel.text = TrainingScheme.numberOfWorkoutsDescription(numberOfWorkouts)
        }
        else{
            numberOfTrainingsLabel.text = "0"
        }
    }
}
