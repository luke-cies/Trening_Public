//
//  WaitView.swift
//  Trening
//
//  Created by Łukasz Cieślik on 22/03/2023.
//

import Foundation
import UIKit

class WaitView: UIView{
    //MARK: - Properties
    private let indicator: UIActivityIndicatorView = {
        let i = UIActivityIndicatorView(style: .large)
        i.startAnimating()
        return i
    }()
    
    //MARK: - Init
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func create() -> WaitView{
        return WaitView(frame: .zero)
    }
    
    //MARK: - UI
    private func setupUI(){
        backgroundColor = .black
        alpha = 0.3
        
        addSubviews(indicator)
        indicator.centerX(inView: self)
        indicator.centerY(inView: self)
    }
}
