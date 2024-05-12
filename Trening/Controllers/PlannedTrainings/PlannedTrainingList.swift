//
//  PlannedTrainingList.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/05/2023.
//

import Foundation
import UIKit

class PlannedTrainingList: GradientTableViewController{
    //MARK: - Propreties
    private let reuseIdentifier = "PlannedTrainingCell"
    private lazy var headerView: HeaderMenuViewAdd = {
        let h = HeaderMenuViewAdd.create { [weak self] in
            self?.viewModel.currentTrainingScheme(.init(withTrainingScheme: TrainingScheme()))
            self?.showTrainingDetails()
        }
        h.title =  "plan.list.title".localized
        h.buttonText = "add".localized
        h.frame = .init(x: 0, y: 0, width: view.frame.width, height: Consts.mainMenuHeight)
        
        return h
    }()
    private var viewModel: PlanViewModelProtocol = PlanViewModel()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI
    private func setupUI(){
        tableView.tableHeaderView = headerView
        tableView.register(TrainingSchemesCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 44
    }
    
    //MARK: - Private
    private func showTrainingDetails(){
        let vc = AddPlannedTrainingController()
        vc.viewModel = viewModel
        vc.changeCompletion = {[weak self] in
            self?.tableView.reloadData()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TrainingSchemesCell
        let data = viewModel[indexPath.row]
        cell.scheme = data
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = viewModel[indexPath.row]{
            viewModel.currentTrainingScheme(.init(withTrainingScheme: data))
            showTrainingDetails()
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            viewModel.removeTraining(at: indexPath) {[weak self] error in
                if let error = error{
                    self?.showError(error.description)
                    return
                }
                tableView.reloadData()
            }
        }
    }
}
