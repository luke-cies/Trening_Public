//
//  SearchBar.swift
//  Trening
//
//  Created by Łukasz Cieślik on 03/04/2023.
//

import Foundation
import UIKit

class SearchBar: UIView{
    //MARK: Properties
    private lazy var textField: UITextField = {
        let t = UITextField()
        t.delegate = self
        t.clearButtonMode = .always
        return t
    }()
    private var completion: ((String) -> Void)!
    
    //MARK: - Init
    init(placeholder: String, textChangedCompletion: @escaping (String) -> Void){
        super.init(frame: .zero)
        self.completion = textChangedCompletion
        textField.placeholder = placeholder
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI
    private func setupUI(){
        setHeight(height: Consts.searchBarHeight)
        addSubviews(textField)
        textField.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingBottom: 5, paddingRight: 10)
    }
}


extension SearchBar: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString : String = textField.text!
        let textRange = Range(range, in: currentString)
        let newString : String = currentString.replacingCharacters(in: textRange!, with: string)
        completion(newString)
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        completion(String())
        return true
    }
}
