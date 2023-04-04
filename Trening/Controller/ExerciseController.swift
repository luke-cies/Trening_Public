//
//  ExerciseController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation
import UIKit

class ExerciseController: GradientBaseController{
    //MARK: - Properties
    let reusableIdentifier: String = "ExerciseCellIdentifier"
    private lazy var tableView: UITableView = {
        let t = UITableView(frame: .zero, style: .plain)
        t.dataSource = self
        t.delegate = self
        t.register(ExerciseCell.self, forCellReuseIdentifier: reusableIdentifier)
        t.backgroundColor = .clear
        t.rowHeight = UITableView.automaticDimension
        t.estimatedRowHeight = 44.0
        t.autoresizingMask = [.flexibleHeight]
        return t
    }()
    private lazy var searchBar = SearchBar(placeholder: "search".localized) {[weak self] searchText in
        self?.viewModel.searchText = searchText
        self?.tableView.reloadData()
    }
    private var viewModel: ExerciseViewModelProtocol = ExerciseViewModel()
    var selectionCompletion: ((Exercise) -> Void)? = nil
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI
    private func setupUI(){
        let headerView = HeaderMenuViewAdd.create { [weak self] in
            self?.showExerciseAlertView(forData: nil)
        }
        headerView.title = "exercise.title".localized
        headerView.buttonText = "add".localized
        
        view.addSubviews(headerView, searchBar)
        headerView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: Consts.mainMenuHeight)
        searchBar.anchor(top: headerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor)
        
        view.addSubviews(tableView)
        tableView.anchor(top: searchBar.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
    }
    
    //MARK: - Private
    private func showExerciseAlertView(forData data: Exercise? = nil){
        showTextFieldAlert(withTitle: data != nil ? "exercise.alert.edit.title".localized : "exercise.alert.add.title".localized,
                           okButtonTitle: "save".localized,
                           cancelButtonTitle: "cancel".localized,
                           text: data?.name) {[weak self] exerciseName in
            if var data = data{
                data.name = exerciseName
                self?.viewModel.updateExercise(data, completion: {[weak self] errMessage in
                    if let errMessage = errMessage{
                        self?.showError(errMessage)
                        return
                    }
                    self?.viewModel.reloadExercises()
                    self?.tableView.reloadData()
                })
            }
            else{
                self?.viewModel.createExercise(exerciseName, completion: {[weak self] errMessage in
                    if let errMessage = errMessage{
                        self?.showError(errMessage)
                        return
                    }
                    self?.viewModel.reloadExercises()
                    self?.tableView.reloadData()
                })
            }
        }
    }
}


extension ExerciseController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.exercises.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableIdentifier, for: indexPath)
        let data = viewModel.exercises[indexPath.row]
        cell.textLabel?.text = data.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return selectionCompletion == nil
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let data = viewModel.exercises[indexPath.row]
            viewModel.removeExercise(data) {[weak self] errMessage in
                if let errMessage = errMessage{
                    self?.showError(errMessage)
                    return
                }
                self?.viewModel.reloadExercises()
                self?.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.exercises[indexPath.row]
        
        if let selectionCompletion = selectionCompletion{
            selectionCompletion(data)
        }
        else{
            showExerciseAlertView(forData: data)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
