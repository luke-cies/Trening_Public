//
//  TrainingRunCell.swift
//  Trening
//
//  Created by Łukasz Cieślik on 04/06/2024.
//

import Foundation
import UIKit

class TrainingRunCell: UITableViewCell {
    //MARK: - Properties
    var data: TrainingData! { didSet{ refresh() }}
    private var serieCounterLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .left)
    private var weightLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    private var repeatsLabel = TLabel(text: String(), font: .systemFont(ofSize: 13), textColor: .TBlackText, textAlignment: .center)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        
    }
    
    //MARK: - Private
    private func refresh() {
        
    }
}
