//
//  SchemesController.swift
//  Trening
//
//  Created by Łukasz Cieślik on 08/05/2024.
//

import Foundation
import UIKit

typealias SchemesControllerCompletion = (TrainingScheme) -> Void

class SchemesController: GradientTableViewController {
    //MARK: - Properties
    private let reuseIdentifier = "SchemesControllerCell"
    private lazy var headerView: HeaderMenuViewAdd = {
        let h = HeaderMenuViewAdd.create{}
        h.title =  "Load scheme".localized
        h.buttonText = nil
        h.frame = .init(x: 0, y: 0, width: view.frame.width, height: Consts.mainMenuHeight)
        return h
    }()
    private var viewModel: TrainingSchemesViewModelProtocol = TrainingSchemesViewModel()
    var completion: SchemesControllerCompletion?
    
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
    
    //MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.trainingSchemes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! TrainingSchemesCell
        let data = viewModel.trainingSchemes[indexPath.row]
        cell.scheme = data
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var data = viewModel.trainingSchemes[indexPath.row]
        completion?(data)
        dismiss(animated: true)
    }
}
