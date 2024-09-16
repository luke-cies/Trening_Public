//
//  TrainingRunHeaderView.swift
//  Trening
//
//  Created by Łukasz Cieślik on 04/06/2024.
//

import Foundation
import UIKit

enum TrainingRunHeaderTypeEnum: Int {
    case prev = 0
    case next = 1
    case addSeries
    case finishExercise
}

typealias TrainingRunHeaderCompletion = (TrainingRunHeaderTypeEnum) -> Void

class TrainingRunHeaderView: UIView {
    //MARK: - Properties
    private var titleLabel = TLabel(text: "training.run.header.title".localized, font: .systemFont(ofSize: Consts.titleFontSize), textColor: .TBlackText, textAlignment: .left)
    private var typeLabel = TLabel(text: "Type:", font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText, textAlignment: .left)
    private var dateLabel = TLabel(text: "Date:", font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText, textAlignment: .left)
    private var exerciseLabel = TLabel(text: "Exercise", font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText, textAlignment: .center)
    private var finishExerciseButton = TButton.create("training.run.header.finishExercise".localized)
    private var nextExerciseButton = TButton.create("training.run.header.nextExercise".localized)
    private var prevExerciseButton = TButton.create("training.run.header.prevExercise".localized)
    private var addSeriesButton = TButton.create("training.run.header.addSeries".localized)
    var completion: TrainingRunHeaderCompletion?
    
    //MARK: - Init
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func create() -> TrainingRunHeaderView{
        let h = TrainingRunHeaderView(frame: .zero)
        return h
    }
    
    //MARK: - UI
    private func setupUI(){
        backgroundColor = .clear
        let line = UIView()
        line.backgroundColor = .TBlack
        
        let stack = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 7, subviews: [titleLabel, typeLabel, dateLabel])
        addSubviews(stack, line)
        
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight, paddingRight: Consts.standardPaddingLeftRight)
        line.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 4, height: 1)
        
        addSubviews(exerciseLabel)
        exerciseLabel.anchor(top: line.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight, paddingRight: Consts.standardPaddingLeftRight, height: 30)
        
        addSubviews(prevExerciseButton, nextExerciseButton)
        prevExerciseButton.setWidth(width: 120)
        prevExerciseButton.tag = TrainingRunHeaderTypeEnum.prev.rawValue
        prevExerciseButton.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        nextExerciseButton.setWidth(width: 120)
        nextExerciseButton.tag = TrainingRunHeaderTypeEnum.next.rawValue
        nextExerciseButton.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        prevExerciseButton.anchor(top: exerciseLabel.bottomAnchor, left: leftAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight)
        nextExerciseButton.anchor(top: exerciseLabel.bottomAnchor, left: prevExerciseButton.rightAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight)
        
        addSubviews(addSeriesButton, finishExerciseButton)
        addSeriesButton.setWidth(width: 100)
        addSeriesButton.tag = TrainingRunHeaderTypeEnum.addSeries.rawValue
        addSeriesButton.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        finishExerciseButton.setWidth(width: 120)
        finishExerciseButton.tag = TrainingRunHeaderTypeEnum.finishExercise.rawValue
        finishExerciseButton.addTarget(self, action: #selector(didTapOnButton), for: .touchUpInside)
        addSeriesButton.anchor(top: prevExerciseButton.bottomAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: Consts.standardPaddingLeftRight)
        finishExerciseButton.anchor(top: addSeriesButton.bottomAnchor, left: leftAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight)
    }
    
    //MARK: - Public
    func update(type: String, date: String, exercise: Exercise) {
        typeLabel.text = "\("training.run.header.type".localized): \(type)"
        dateLabel.text = "\("training.run.header.date".localized): \(date)"
        exerciseLabel.text = exercise.name
    }
    
    //MARK: - Events
    @objc private func didTapOnButton(_ sender: TButton) {
        if let type = TrainingRunHeaderTypeEnum(rawValue: sender.tag){
            completion?(type)
        }
    }
}
