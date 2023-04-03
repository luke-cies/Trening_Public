//
//  AddTrainingSchemeCell.swift
//  Trening
//
//  Created by Łukasz Cieślik on 30/03/2023.
//

import Foundation
import UIKit

class AddTrainingSchemeCell: UITableViewCell{
    //MARK: - Properties
    private let weightLabel = TLabel(text: String(), font: .systemFont(ofSize: 12), textColor: .TBlackText,  textAlignment: .right)
    private let exerciseNameLabel = TLabel(text: String(), font: .boldSystemFont(ofSize: 12), textColor: .TBlackText)
    private let numberOfSeriesLabel = TLabel(text: String(), font: .systemFont(ofSize: 12), textColor: .TBlackText)
    var schemeData: TrainingSchemeData?{
        didSet{
            configure()
        }
    }
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let dataStack = UIStackView(axis: .horizontal, distribution: .fill, subviews: [numberOfSeriesLabel, weightLabel])
        let stack = UIStackView(axis: .vertical, distribution: .fillEqually, subviews: [exerciseNameLabel, dataStack])
        numberOfSeriesLabel.setWidth(width: 100)
        
        addSubviews(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 15, paddingBottom: 10, paddingRight: 15)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func configure(){
        exerciseNameLabel.text = schemeData?.exercise.name
        if let numberOfSeries = schemeData?.numberOfSeries.description{
            let numberOfSeriesText = "\("trainingScheme.add.tableViewCell.NumberOfSeries".localized) \(numberOfSeries)"
            let numberOfSeriesBoldText = numberOfSeriesText.getBoldAtributedString(highlightedTextsArray: [numberOfSeries], fontSize: 14)
            numberOfSeriesLabel.attributedText = numberOfSeriesBoldText
        }
        
        if let weight = schemeData?.weight, let addWeight = schemeData?.addWeight{
            let weightText = "\("trainingScheme.add.tableViewCell.weight".localized) \(weight) / \(addWeight)"
            let weightBoldText = weightText.getBoldAtributedString(highlightedTextsArray: ["\(weight) / \(addWeight)"], fontSize: 14)
            weightLabel.attributedText = weightBoldText
        }
    }
}
