//
//  AddTrainingSchemeController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 24/03/2023.
//

import Foundation
import UIKit


class AddTrainingSchemeController: GradientBaseController{
    //MARK: - Properties
    private let reuseIdentifier = "AddTrainingSchemeCellIdentifier"
    var viewModel: TrainingSchemesViewModelProtocol?
    private var isEdit: Bool{
        viewModel?.currentTrainingScheme.userId != ""
    }
    private lazy var schemeHeaderView: UIView = {
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
    private lazy var exercisesHeaderView: HeaderMenuViewAdd = HeaderMenuViewAdd.create {[weak self] in
        self?.didTapOnAddButton()
    }
    private lazy var sortButton: TButton = {
        let b = TButton.create("sort".localized)
        b.isEnabled = false
        b.addTarget(self, action: #selector(didTapOnSortButton), for: .touchUpInside)
        
        return b
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
    private var isTableInEdit = false
    var changeCompletion: (() -> Void)?
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        exercisesHeaderView.isButtonEnabled = isEdit
        sortButton.isEnabled = isEdit
        setupUI()
        setupData()
    }
    
    //MARK: - UI
    private func setupUI(){
        let headerView = HeaderMenuViewAdd.create { [weak self] in
            self?.save()
        }
        headerView.title = "trainingScheme.add.title".localized
        headerView.buttonText = "save".localized
        
        exercisesHeaderView.title = "trainingScheme.add.exercises.title".localized
        exercisesHeaderView.titleFont = .boldSystemFont(ofSize: Consts.standardLabelFontSize)
        exercisesHeaderView.buttonText = "add".localized
        
        view.addSubviews(headerView, schemeHeaderView, exercisesHeaderView, tableView)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: Consts.mainMenuHeight)
        typeSegmentedControl.addTarget(self, action: #selector(typeDidChanged), for: .valueChanged)
        schemeHeaderView.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        exercisesHeaderView.anchor(top: schemeHeaderView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, height: Consts.mainMenuHeight)
        tableView.anchor(top: exercisesHeaderView.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingTop: 10)
        
        nameTextField.textAlignment = .right
        numberOfTrainings.textAlignment = .right
        numberOfTrainings.keyboardType = .numberPad
    }
    
    //MARK: - Private
    private func setupData(){
        typeSegmentedControl.selectedSegmentIndex = viewModel?.currentTrainingScheme.trainingMethod.value ?? 0
        numberOfTrainingsLabel.text = typeSegmentedControl.selectedSegmentIndex == 0 ? "trainingScheme.add.numberOfTrainingsLabel.hst".localized : "trainingScheme.add.numberOfTrainingsLabel".localized
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
    
    //MARK: - Events
    @objc private func didTapOnAddButton(){
        showDataController(schemeData: TrainingSchemeData())
    }
    
    @objc private func didTapOnSortButton(){
        isTableInEdit = !isTableInEdit
        tableView.isEditing = isTableInEdit
    }
    
    @objc private func typeDidChanged(sender: UISegmentedControl){
        numberOfTrainingsLabel.text = sender.selectedSegmentIndex == 0 ? "trainingScheme.add.numberOfTrainingsLabel.hst".localized : "trainingScheme.add.numberOfTrainingsLabel".localized
//        viewModel?.currentTrainingScheme.trainingMethod = TrainingMethod.create(value: sender.selectedSegmentIndex)
    }
    
    //MARK: - Private
    private func save(){
        guard validate() else {return}
        
        if isEdit == true{
            if var scheme = viewModel?.currentTrainingScheme{
                if let numberoOfWorkouts = numberOfTrainings.text!.integer{
                    scheme.numberOfWorkouts = numberoOfWorkouts
                }
                
                if let name = nameTextField.text, name.count > 0{
                    scheme.name = name
                }
                
                scheme.trainingMethod = TrainingMethod.create(value: typeSegmentedControl.selectedSegmentIndex)
                viewModel?.updateTrainingScheme(scheme, completion: {[weak self] err in
                    if let err = err{
                        self?.showError(err.description)
                        return
                    }
                    self?.viewModel?.refreshCurrentTrainingScheme()
                    self?.tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
                    self?.sortButton.isEnabled = true
                    self?.changeCompletion?()
                })
            }
        }
        else{//create
            guard let userId = viewModel?.loggedUserId, userId.count > 0 else {return}
            var credentials = TrainingSchemeCredentials(trainingMethod: TrainingMethod.create(value: typeSegmentedControl.selectedSegmentIndex), numberOfWorkouts: 0, trainingType: .scheme, trainingSchemeData: [TrainingSchemeDataCredentialsProtocol](), userId: userId)
            
            if let numberoOfWorkouts = numberOfTrainings.text!.integer{
                credentials.numberOfWorkouts = numberoOfWorkouts
            }
            
            if let name = nameTextField.text, name.count > 0{
                credentials.name = name
            }
            
            viewModel?.addTrainingScheme(credentials, completion: {[weak self] err, trScheme in
                if let err = err{
                    self?.showError(err.description)
                    return
                }
                
                if let trScheme = trScheme{
                    self?.viewModel?.currentTrainingScheme(.init(withTrainingScheme: trScheme))
                    self?.tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
                    self?.sortButton.isEnabled = true
                    self?.changeCompletion?()
                }
            })
        }
    }
    
    private func validate() -> Bool{
        if let text = numberOfTrainings.text, text.count > 0, (text.integer ?? 0) > 0 {
            return true
        }
        
        showError("trainingScheme.add.error.numberOfTrainings".localized)
        return false
    }
    
    private func showDataController(schemeData: TrainingSchemeData){
        let vc = AddTrainingSchemeDataController()
        vc.delegate = self
        vc.schemeData = schemeData
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

//MARK: - TableView
extension AddTrainingSchemeController: UITableViewDelegate, UITableViewDataSource{
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
                viewModel?.removeSchemeData(data, completion: {[weak self] err in
                    if let err = err {
                        self?.showError(err.description)
                        return
                    }
                    self?.viewModel?.refreshCurrentTrainingScheme()
                    tableView.reloadData()
                    self?.exercisesHeaderView.isButtonEnabled = true
                    self?.sortButton.isEnabled = true
                })
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel?.moveSchemeData(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
}


//MARK: - AddTrainingSchemeDataControllerDelegate
extension AddTrainingSchemeController: AddTrainingSchemeDataControllerDelegate{
    func savedSchemeData(_ data: TrainingSchemeData, forEdit: Bool) {
        if forEdit == false{
            viewModel?.addSchemeData(data, completion: {[weak self] err, trData in
                if let err = err{
                    self?.showError(err.description)
                    return
                }
                self?.viewModel?.refreshCurrentTrainingScheme()
                self?.tableView.reloadData()
            })
        }
        else{
            viewModel?.updateSchemeData(data, completion: {[weak self] err in
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
