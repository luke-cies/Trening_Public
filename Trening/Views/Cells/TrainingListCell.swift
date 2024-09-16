//
//  TrainingListCell.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/05/2024.
//

import Foundation
import UIKit

class TrainingListCell: UITableViewCell {
    //MARK: - Properties
    private var typeLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private var subTypeLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private var trainingNumberLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private var dateLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private var statusLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private lazy var button: UIView = {
        let v = UIView()
        let img = UIImageView(image: UIImage(systemName: "chevron.right.circle"))
        img.tintColor = .TDarkGray
        v.addSubviews(img)
        img.centerXY(in: v)
        v.setWidth(width: 30)
        return v
    }()
    var training: Training? {
        didSet {
            configure()
        }
    }
    
    //MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let stack = UIStackView(axis: .horizontal, alignment: .fill, distribution: .fill, spacing: 10, subviews: [typeLabel, subTypeLabel, trainingNumberLabel, dateLabel, statusLabel, button])
        addSubviews(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 3, paddingLeft: 5, paddingBottom: 3, paddingRight: 3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private
    private func configure(){
        if let training = training {
            typeLabel.text = training.trainingMethod.rawValue
            subTypeLabel.text = training.subType.description
            trainingNumberLabel.text = "\(training.trainingCounter) \("of".localized) \(training.plannedNumberOfWorkouts)"
            dateLabel.text = training.createDate.formatted(date: .long, time: .omitted)
            statusLabel.text = training.status.description
        }
        else {
            typeLabel.text = nil
            subTypeLabel.text = nil
            trainingNumberLabel.text = nil
            dateLabel.text = nil
            statusLabel.text = nil
        }
    }
}
