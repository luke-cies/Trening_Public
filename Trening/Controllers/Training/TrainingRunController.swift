//
//  TrainingRunController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 24/05/2024.
//

import Foundation
import UIKit

class TrainingRunController: GradientTableViewController {
    //MARK: - Properties
    var viewModel: TrainingViewModelRunProtocol!
    private let reuseIdentifier = "TrainingRunCell"
    private lazy var headerView: TrainingRunHeaderView = {
        let h = TrainingRunHeaderView.create()
        h.frame = .init(x: 0, y: 0, width: view.frame.width, height: Consts.trainingRunHeaderHeight)
        h.completion = {[weak self] (type: TrainingRunHeaderTypeEnum) in
            switch type {
            case .prev:
                print("prev")
            case .next:
                print("next")
            case .addSeries:
                print("add series")
            case .finishExercise:
                print("Finish Exercise")
            }
        }
        return h
    }()
    
    //MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    //MARK: - UI
    private func setupUI() {
        tableView.tableHeaderView = headerView
        tableView.register(TrainingRunCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 44
        
        headerView.update(type: viewModel.currentTraining.subType.description, date: Date.now.getString(), exercise: viewModel.currentTrainingData.exercise)
    }
    
    //MARK: - Private
    
    
    //MARK: - TableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.currentTraining.trainingData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TrainingRunCell
        let data = viewModel.currentTraining.trainingData[indexPath.row]
        cell.data = data
        
        return cell
    }
}
