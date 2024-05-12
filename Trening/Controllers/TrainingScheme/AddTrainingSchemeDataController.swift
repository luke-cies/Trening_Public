//
//  AddTrainingSchemeDataController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 31/03/2023.
//

import Foundation
import UIKit

protocol AddTrainingSchemeDataControllerDelegate: AnyObject{
    func savedSchemeData(_ data: TrainingSchemeData, forEdit: Bool)
}

class AddTrainingSchemeDataController: GradientBaseController{
    //MARK: - Properties
    weak var delegate: AddTrainingSchemeDataControllerDelegate?
    var schemeData: TrainingSchemeData!
    private var exerciseNameLabel = TLabel(text: String(), font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
    private var numberOfSeriesTextField = CustomTextField(placeholder: "trainingScheme.add.data.numberOfSeries.placeholder".localized)
    private var weightTextField = CustomTextField(placeholder: "trainingScheme.add.data.weight.placeholder".localized)
    private var addWeightTextField = CustomTextField(placeholder: "trainingScheme.add.data.addWeight.placeholder".localized)
    private var isEdit: Bool!
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        isEdit = !schemeData.exercise.name.isEmpty
        setupUI()
        setupData()
    }
    
    //MARK: - UI
    private func setupUI(){
        let titleLabelWidth: CGFloat = 100
        let exerciseButton = TButton.create("trainingScheme.add.data.exercise.change".localized)
        exerciseButton.addTarget(self, action: #selector(didTapOnExerciseButton), for: .touchUpInside)
        let exerciseTitleLabel = TLabel(text: "trainingScheme.add.data.exercise".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        let numberOfSeriesTitleLabel = TLabel(text: "trainingScheme.add.data.numberOfSeries".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        let weightTitleLabel = TLabel(text: "trainingScheme.add.data.weight".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        let addWeightTitleLabel = TLabel(text: "trainingScheme.add.data.addWeight".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        
        let exerciseStack = UIStackView(axis: .horizontal, spacing: 5, subviews: [exerciseTitleLabel, exerciseNameLabel, exerciseButton])
        exerciseTitleLabel.setWidth(width: titleLabelWidth)
        exerciseNameLabel.setHeight(height: Consts.buttonHeight)
        
        let exerciseButtonStack = UIStackView(axis: .horizontal, spacing: 5, subviews: [UIView(), exerciseButton])
        exerciseButton.setWidth(width: 135)
        
        let numberOfSeriesStack = UIStackView(axis: .horizontal, spacing: 5, subviews: [numberOfSeriesTitleLabel, numberOfSeriesTextField])
        numberOfSeriesTitleLabel.setWidth(width: titleLabelWidth)
        
        let weightStack = UIStackView(axis: .horizontal, spacing: 5, subviews: [weightTitleLabel, weightTextField])
        weightTitleLabel.setWidth(width: titleLabelWidth)
        
        let addWeightStack = UIStackView(axis: .horizontal, spacing: 5, subviews: [addWeightTitleLabel, addWeightTextField])
        addWeightTitleLabel.setWidth(width: titleLabelWidth)
        
        let saveButton = TButton.create("save".localized)
        saveButton.addTarget(self, action: #selector(didTapOnSaveButton), for: .touchUpInside)
        
        let cancelButton = TButton.create("cancel".localized)
        cancelButton.addTarget(self, action: #selector(didTapOnCancelButton), for: .touchUpInside)
        
        let buttonsStack = UIStackView(axis: .horizontal, distribution: .fillEqually, spacing: 5, subviews: [UIView(), cancelButton, saveButton, UIView()])
        addWeightTitleLabel.setWidth(width: titleLabelWidth)
        
        let stack = UIStackView(axis: .vertical, spacing: 20, subviews: [exerciseStack, exerciseButtonStack, numberOfSeriesStack, weightStack, addWeightStack, UIView(), buttonsStack, UIView()])
        
        view.addSubviews(stack)
        stack.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 80, paddingLeft: 20, paddingRight: 20, height: 450)
        
        numberOfSeriesTextField.keyboardType = .numberPad
        weightTextField.keyboardType = .decimalPad
        addWeightTextField.keyboardType = .decimalPad
    }
    
    private func setupData(){
        exerciseNameLabel.text = schemeData.exercise.name
        numberOfSeriesTextField.placeholder = schemeData.numberOfSeries.description
        weightTextField.placeholder = schemeData.weight.description
        addWeightTextField.placeholder = schemeData.addWeight.description
    }
    
    //MARK: - Events
    @objc private func didTapOnExerciseButton(){
        let vc =  ExerciseController()
        vc.selectionCompletion = {[weak self] selectedExercise in
            self?.exerciseNameLabel.text = selectedExercise.name
            self?.schemeData.exercise = selectedExercise
            self?.dismiss(animated: true)
        }
        present(vc, animated: true)
    }
    
    @objc private func didTapOnSaveButton(){
        if schemeData.exercise.name.isEmpty{
            showError("trainingScheme.add.data.error.exercise".localized)
            return
        }
        
        if let text = numberOfSeriesTextField.text, text.count > 0{
            if let value = text.integer{
                schemeData.numberOfSeries = value
            }
            else{
                showError("trainingScheme.add.data.error.numberOfSeries".localized)
                return
            }
        }
        
        if let text = weightTextField.text, text.count > 0{
            if let value = text.double{
                schemeData.weight = value
            }
            else{
                showError("trainingScheme.add.data.error.weight".localized)
                return
            }
        }
        
        if let text = addWeightTextField.text, text.count > 0{
            if let value = text.double{
                schemeData.addWeight = value
            }
            else{
                showError("trainingScheme.add.data.error.addWeight".localized)
                return
            }
        }
        
        delegate?.savedSchemeData(schemeData, forEdit: isEdit)
        
        Logger.log("Add/Edit Training scheme data: \(schemeData!)")
        dismiss(animated: true)
    }
    
    @objc private func didTapOnCancelButton(){
        dismiss(animated: true)
    }
}

//MARK: - UITextFieldDelegate
extension AddTrainingSchemeDataController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        return true
    }
}
