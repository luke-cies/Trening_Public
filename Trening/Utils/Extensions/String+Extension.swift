//
//  String+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 09/03/2023.
//

import Foundation
import UIKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    
    func getBoldAtributedString(highlightedTextsArray: [String]) -> NSAttributedString{
        let mutString: NSMutableString = NSMutableString(string: self)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        
        for bText in highlightedTextsArray{
            let range: NSRange = mutString.range(of: bText, options: .caseInsensitive)
            if range.length == 0{
                continue
            }
            
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)]
            let boldAttrText = NSMutableAttributedString(string: bText, attributes: attrs)
            
            attributedString.replaceCharacters(in: range, with: boldAttrText)
        }
        
        return attributedString
    }
}
