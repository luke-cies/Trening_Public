//
//  TrainingList.swift
//  Trening
//
//  Created by Łukasz Cieślik on 16/05/2024.
//

import Foundation
import UIKit

class TrainingList: GradientTableViewController {
    //MARK: - Propreties
    private let reuseIdentifier = "TrainingListCell"
    private var viewModel: TrainingViewModelProtocol = TrainingViewModel()
    private lazy var headerView: HeaderMenuViewAdd = {
        let h = HeaderMenuViewAdd.create { [weak self] in
            
        }
        h.title =  "training.list.title".localized
        h.buttonText = "training.list.showHistory".localized
        h.frame = .init(x: 0, y: 0, width: view.frame.width, height: Consts.mainMenuHeight)
        
        return h
    }()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI
    private func setupUI(){
        tableView.tableHeaderView = headerView
        tableView.register(TrainingListCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 44
    }
    
    //MARK: - Private
    private func showRunTrainingController() {
        let vc = TrainingRunController()
        vc.viewModel = viewModel
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.allTrainings.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TrainingListCell
        let data = viewModel[indexPath.row]
        cell.training = data
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = viewModel[indexPath.row]{
            viewModel.setCurrentTraining(data)
            showRunTrainingController()
        }
    }
}
