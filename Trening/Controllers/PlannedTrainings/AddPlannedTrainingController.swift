//
//  AddPlannedTrainingController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 24/05/2023.
//

import Foundation
import UIKit

class AddPlannedTrainingController: GradientBaseController{
    //MARK: - Properties
    var viewModel: PlanViewModelProtocol?
    var changeCompletion: (() -> Void)?
    private let reuseIdentifier = "AddPlannedTrainingCellIdentifier"
    private var isEdit: Bool{ viewModel?.currentTrainingScheme.userId != "" }
    private lazy var trainingHeaderView: UIView = {
        let v = UIView(frame: .zero)
        
        var typeLabel = TLabel(text: "trainingScheme.add.typeLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        var nameLabel = TLabel(text: "trainingScheme.add.nameLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        var typeStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [typeLabel, typeSegmentedControl])
        var nameStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [nameLabel, nameTextField])
        var numberOfTrainingsStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [numberOfTrainingsLabel, numberOfTrainings])
        let stack = UIStackView(axis: .vertical, distribution: .fillEqually, spacing: 15, subviews: [typeStack, nameStack, numberOfTrainingsStack])
        v.addSubviews(stack)
        
        typeSegmentedControl.setWidth(width: 100)
        stack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, right: v.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10)
        v.setHeight(height: 100)
        
        return v
    }()
    private var typeSegmentedControl: UISegmentedControl = UISegmentedControl(items: [TrainingMethod.HST.rawValue, TrainingMethod.FBW.rawValue])
    private var nameTextField = CustomTextField(placeholder: "trainingScheme.add.name".localized)
    private var numberOfTrainings = CustomTextField(placeholder: "trainingScheme.add.numberOfTrainings".localized)
    private var numberOfTrainingsLabel = TLabel(text: "trainingScheme.add.typeLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
    private lazy var exercisesHeaderView: UIView = {
        let v = UIView(frame: .zero)
        let titleLabel = TLabel(text: "trainingScheme.add.exercises.title".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        let stack = UIStackView(axis: .horizontal, spacing: 10, subviews: [titleLabel, addButton])
        v.addSubviews(stack)
        stack.pinToEdges(of: v)
        addButton.setWidth(width: 80)
        return v
    }()
    private lazy var addButton: TButton = {
        let addButton = TButton.create("add".localized)
        addButton.isEnabled = false
        addButton.addTarget(self, action: #selector(didTapOnAddButton), for: .touchUpInside)
        
        return addButton
    }()
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero)
        t.delegate = self
        t.dataSource = self
        t.register(AddTrainingSchemeCell.self, forCellReuseIdentifier: reuseIdentifier)
        t.backgroundColor = .TBlack.withAlphaComponent(0.1)
        t.rowHeight = 74
        t.separatorColor = .TBlack
        return t
    }()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        addButton.isEnabled = isEdit
        setupData()
    }
    
    //MARK: - UI
    private func setupUI(){
        let headerView = HeaderMenuViewAdd.create { [weak self] in
            self?.save()
        }
        headerView.title = "trainingScheme.add.title".localized
        headerView.buttonText = "save".localized
        
        view.addSubviews(headerView, trainingHeaderView, exercisesHeaderView, tableView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: Consts.mainMenuHeight)
        typeSegmentedControl.addTarget(self, action: #selector(typeDidChanged), for: .valueChanged)
        trainingHeaderView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        exercisesHeaderView.anchor(top: trainingHeaderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        tableView.anchor(top: exercisesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10)
        
        nameTextField.textAlignment = .right
        numberOfTrainings.textAlignment = .right
        numberOfTrainings.keyboardType = .numberPad
    }
    
    //MARK: - Private
    private func setupData(){
        typeSegmentedControl.selectedSegmentIndex = viewModel?.currentTrainingScheme.trainingMethod.value ?? 0
        nameTextField.placeholder = viewModel?.currentTrainingScheme.name
        numberOfTrainingsLabel.text = typeSegmentedControl.selectedSegmentIndex == 0 ? "trainingScheme.add.numberOfTrainingsLabel.hst".localized : "trainingScheme.add.numberOfTrainingsLabel".localized
        numberOfTrainings.placeholder = viewModel?.currentTrainingScheme.numberOfWorkouts.description
        
        tableView.reloadData()
    }
    
    private func save(){
        
    }
    
    private func validate() -> Bool{
        if let text = numberOfTrainings.text, text.count > 0{
            if text.integer == nil{
                showError("trainingScheme.add.error.numberOfTrainings".localized)
                return false
            }
        }
        return true
    }
    
    private func showDataController(schemeData: TrainingSchemeData){
        let vc = AddTrainingSchemeDataController()
        vc.delegate = self
        vc.schemeData = schemeData
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    //MARK: - Events
    @objc private func didTapOnAddButton(){
//        showDataController(schemeData: TrainingSchemeData())
    }
    
    @objc private func typeDidChanged(sender: UISegmentedControl){
//        numberOfTrainingsLabel.text = sender.selectedSegmentIndex == 0 ? "trainingScheme.add.numberOfTrainingsLabel.hst".localized : "trainingScheme.add.numberOfTrainingsLabel".localized
////        viewModel?.currentTrainingScheme.trainingMethod = TrainingMethod.create(value: sender.selectedSegmentIndex)
    }
}


//MARK: - TableView
extension AddPlannedTrainingController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AddTrainingSchemeCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
    }
}


//MARK: - AddTrainingSchemeDataControllerDelegate
extension AddPlannedTrainingController: AddTrainingSchemeDataControllerDelegate{
    func savedSchemeData(_ data: TrainingSchemeData, forEdit: Bool) {
        
    }
}
