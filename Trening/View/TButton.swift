//
//  TButton.swift
//  Trening
//
//  Created by Łukasz Cieślik on 23/03/2023.
//

import Foundation
import UIKit


class TButton: UIControl{
    //MARK: - Properties
    private var lbl: UILabel = {
        let l = UILabel(frame: .zero)
        l.font = .boldSystemFont(ofSize: 12)
        l.textColor = .white
        l.textAlignment = .center
        return l
    }()
    var title: String = String(){
        didSet{
            lbl.text = title
        }
    }
    var fontSize: CGFloat = 12{
        didSet{
            lbl.font = .boldSystemFont(ofSize: fontSize)
        }
    }
    
    //MARK: - Init
    private override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func create(_ title: String) -> TButton{
        let b = TButton(frame: .zero)
        b.title = title
        return b
    }
    
    //MARK: - UI
    private func setupUI(){
        backgroundColor = .TButtonGray
        setHeight(height: 50)
        
        addSubviews(lbl)
        lbl.pinToEdges(of: self)
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
}
