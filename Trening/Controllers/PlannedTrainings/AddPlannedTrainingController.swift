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
        
        var typeLabel = TLabel(text: "plan.add.typeLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        var subTypeLabel = TLabel(text: "plan.add.subTypeLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        var nameLabel = TLabel(text: "plan.add.nameLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
        var typeStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [typeLabel, typeSegmentedControl])
        var subTypeStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [subTypeLabel, subTypeSegmentedControl])
        var nameStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [nameLabel, nameTextField])
        var numberOfTrainingsStack = UIStackView(axis: .horizontal, spacing: 10, subviews: [numberOfTrainingsLabel, numberOfTrainings])
        let stack = UIStackView(axis: .vertical, distribution: .fillEqually, spacing: 15, subviews: [typeStack, subTypeStack, nameStack, numberOfTrainingsStack])
        v.addSubviews(stack)
        
        typeSegmentedControl.setWidth(width: 100)
        subTypeSegmentedControl.setWidth(width: 250)
        stack.anchor(top: v.topAnchor, left: v.leftAnchor, bottom: v.bottomAnchor, right: v.rightAnchor, paddingTop: Consts.standardPaddingTopBottom, paddingLeft: Consts.standardPaddingLeftRight, paddingBottom: Consts.standardPaddingTopBottom, paddingRight: Consts.standardPaddingLeftRight)
        v.setHeight(height: 150)
        
        return v
    }()
    private var typeSegmentedControl: UISegmentedControl = UISegmentedControl(items: [TrainingMethod.HST.rawValue, TrainingMethod.FBW.rawValue])
    private var subTypeSegmentedControl: UISegmentedControl = UISegmentedControl(items: [TrainingSubType.mass.description, TrainingSubType.reduction.description, TrainingSubType.deload.description])
    private var nameTextField = CustomTextField(placeholder: "plan.add.name".localized)
    private var numberOfTrainings = CustomTextField(placeholder: "plan.add.numberOfTrainings".localized)
    private var numberOfTrainingsLabel = TLabel(text: "plan.add.typeLabel".localized, font: .systemFont(ofSize: Consts.standardLabelFontSize), textColor: .TBlackText)
    private lazy var exercisesHeaderView: HeaderMenuViewAdd = HeaderMenuViewAdd.create {[weak self] in
        self?.didTapOnAddButton()
    }
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
        exercisesHeaderView.isButtonEnabled = isEdit
        setupData()
    }
    
    //MARK: - UI
    private func setupUI(){
        let headerView = HeaderMenuViewAdd.create { [weak self] in
            self?.save()
        }
        headerView.title = "plan.add.title".localized
        headerView.buttonText = "save".localized
        
        let loadSchemeView = ButtonsView()
        loadSchemeView.data = [.init(title: "plan.add.loadScheme".localized, isEnabled: !isEdit), .init(title: "plan.add.run".localized, isEnabled: isEdit)]
        loadSchemeView.buttonsOnTheLeft = true
        loadSchemeView.buttonTapActionCompletion = { [weak self] (buttonNumber: Int) in
            if buttonNumber == 0 {//load scheme
                self?.showLoadSchemeController()
            }
            else if buttonNumber == 1 { //Create trainings
                self?.runCurrentPlan()
            }
        }
        
        exercisesHeaderView.title = "plan.add.exercises.title".localized
        exercisesHeaderView.titleFont = .boldSystemFont(ofSize: Consts.standardLabelFontSize)
        exercisesHeaderView.buttonText = "add".localized
        
        view.addSubviews(headerView, loadSchemeView, trainingHeaderView, exercisesHeaderView, tableView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: Consts.mainMenuHeight)
        loadSchemeView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 10, paddingRight: 10)
        typeSegmentedControl.addTarget(self, action: #selector(segmentedControlDidChanged), for: .valueChanged)
        subTypeSegmentedControl.addTarget(self, action: #selector(segmentedControlDidChanged), for: .valueChanged)
        
        trainingHeaderView.anchor(top: loadSchemeView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10)
        exercisesHeaderView.anchor(top: trainingHeaderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, height: Consts.mainMenuHeight)
        tableView.anchor(top: exercisesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
        nameTextField.textAlignment = .right
        numberOfTrainings.textAlignment = .right
        numberOfTrainings.keyboardType = .numberPad
    }
    
    //MARK: - Private
    private func setupData(){
        typeSegmentedControl.selectedSegmentIndex = viewModel?.currentTrainingScheme.trainingMethod.value ?? 0
        subTypeSegmentedControl.selectedSegmentIndex = viewModel?.currentTrainingScheme.subType.rawValue ?? 0
        numberOfTrainingsLabel.text = typeSegmentedControl.selectedSegmentIndex == 0 ? "plan.add.numberOfTrainingsLabel.hst".localized : "plan.add.numberOfTrainingsLabel".localized
        
        if let isNew = viewModel?.currentTrainingScheme.isNew, isNew {
            nameTextField.placeholder = viewModel?.currentTrainingScheme.name
            numberOfTrainings.placeholder = viewModel?.currentTrainingScheme.numberOfWorkouts.description
        }
        else {
            nameTextField.text = viewModel?.currentTrainingScheme.name
            numberOfTrainings.text = viewModel?.currentTrainingScheme.numberOfWorkouts.description
        }
        
        tableView.reloadData()
    }
    
    private func save() {
        guard validate() else { return }
        
        if isEdit == true {
            if var scheme = viewModel?.currentTrainingScheme {
                if let numberoOfWorkouts = numberOfTrainings.text!.integer{
                    scheme.numberOfWorkouts = numberoOfWorkouts
                }
                
                if let name = nameTextField.text, name.count > 0{
                    scheme.name = name
                }
                
                scheme.trainingMethod = TrainingMethod.create(value: typeSegmentedControl.selectedSegmentIndex)
                scheme.subType = TrainingSubType(rawValue: subTypeSegmentedControl.selectedSegmentIndex) ?? .mass
                
                viewModel?.updateTrainingPlan(scheme, completion: { [weak self] (err: TrainingSchemeError?) in
                    if let err = err{
                        self?.showError(err.description)
                        return
                    }
                    
                    self?.viewModel?.refreshCurrentTrainingScheme()
                    self?.tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
//                    self?.sortButton.isEnabled = true
                    self?.changeCompletion?()
                })
            }
        }
        else {//create
            guard let userId = viewModel?.loggedUserId, userId.count > 0 else {return}
            var credentials = TrainingSchemeCredentials(trainingMethod: TrainingMethod.create(value: typeSegmentedControl.selectedSegmentIndex), numberOfWorkouts: 0, trainingType: .plan, subType: (TrainingSubType(rawValue: subTypeSegmentedControl.selectedSegmentIndex) ?? .mass), trainingSchemeData: [TrainingSchemeDataCredentialsProtocol](), userId: userId)
            
            if let numberoOfWorkouts = numberOfTrainings.text!.integer{
                credentials.numberOfWorkouts = numberoOfWorkouts
            }
            
            if let name = nameTextField.text, name.count > 0{
                credentials.name = name
            }
            
            viewModel?.addTrainingPlan(credentials, completion: { [weak self] (err: TrainingSchemeError?, trScheme: TrainingScheme?) in
                if let err = err{
                    self?.showError(err.description)
                    return
                }
                
                if let trScheme = trScheme{
                    let data: [TrainingSchemeData]
                    if let schemeData = self?.viewModel?.currentTrainingScheme.trainingSchemeData {
                        data = schemeData
                    }
                    else {
                        data = [TrainingSchemeData]()
                    }
                    
                    self?.viewModel?.currentTrainingScheme(.init(withTrainingScheme: trScheme))
                    self?.tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
//                    self?.sortButton.isEnabled = true
                    self?.changeCompletion?()
                    
                    //Save Data
                    data.forEach{ self?.savedSchemeData($0, forEdit: false)}
                }
            })
        }
    }
    
    private func validate() -> Bool{
        if let text = numberOfTrainings.text, text.count > 0, (text.integer ?? 0) > 0 {
            return true
        }
        
        showError("plan.add.error.numberOfTrainings".localized)
        return false
    }
    
    private func showDataController(schemeData: TrainingSchemeData){
        let vc = AddTrainingSchemeDataController()
        vc.delegate = self
        vc.schemeData = schemeData
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func showLoadSchemeController() {
        let vc = SchemesController()
        vc.modalPresentationStyle = .formSheet
        vc.completion = { [weak self] (scheme: TrainingScheme) in
            self?.loadscheme(scheme)
        }
        present(vc, animated: true)
    }
    
    private func loadscheme(_ scheme: TrainingScheme) {
        viewModel?.loadScheme(scheme)
        setupData()
    }
    
    private func runCurrentPlan() {
        viewModel?.runCurrentPlan{ (error: TrainingError?) in
            if let error = error {
                let alert = UIAlertController(title: "error".localized, message: error.description, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized, style: .default))
                self.present(alert, animated: true)
                return
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    //MARK: - Events
    @objc private func didTapOnAddButton(){
        showDataController(schemeData: TrainingSchemeData(trainingType: .plan))
    }
    
    @objc private func segmentedControlDidChanged(sender: UISegmentedControl){
        if sender == typeSegmentedControl {
            numberOfTrainingsLabel.text = sender.selectedSegmentIndex == 0 ? "plan.add.numberOfTrainingsLabel.hst".localized : "plan.add.numberOfTrainingsLabel".localized
            //        viewModel?.currentTrainingScheme.trainingMethod = TrainingMethod.create(value: sender.selectedSegmentIndex)
        }
        else if sender == subTypeSegmentedControl {
            //Do nothing
        }
    }
}


//MARK: - TableView
extension AddPlannedTrainingController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.currentTrainingScheme.trainingSchemeData.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! AddTrainingSchemeCell
        let data = viewModel?.currentTrainingScheme.trainingSchemeData[indexPath.row]
        cell.schemeData = data
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let schemeData = viewModel?.currentTrainingScheme.trainingSchemeData[indexPath.row]{
            showDataController(schemeData: schemeData)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            if let data = viewModel?.currentTrainingScheme.trainingSchemeData[indexPath.row]{
                viewModel?.removePlanData(data, completion: {[weak self] err in
                    if let err = err {
                        self?.showError(err.description)
                        return
                    }
                    self?.viewModel?.refreshCurrentTrainingScheme()
                    tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
//                    self?.sortButton.isEnabled = true
                })
            }
        }
    }
}


//MARK: - AddTrainingSchemeDataControllerDelegate
extension AddPlannedTrainingController: AddTrainingSchemeDataControllerDelegate{
    func savedSchemeData(_ data: TrainingSchemeData, forEdit: Bool) {
        if forEdit == false{
            viewModel?.addPlanData(data, completion: {[weak self] err, trData in
                if let err = err{
                    self?.showError(err.description)
                    return
                }
                self?.viewModel?.refreshCurrentTrainingScheme()
                self?.tableView.reloadData()
            })
        }
        else{
            viewModel?.updatePlanData(data, completion: {[weak self] err in
                if let err = err{
                    self?.showError(err.description)
                    return
                }
                self?.viewModel?.refreshCurrentTrainingScheme()
                self?.tableView.reloadData()
            })
        }
    }
}
