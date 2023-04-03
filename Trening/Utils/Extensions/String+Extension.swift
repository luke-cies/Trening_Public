//
//  String+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 09/03/2023.
//

import Foundation
import UIKit
import CryptoKit

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    
    func getBoldAtributedString(highlightedTextsArray: [String], fontSize: CGFloat) -> NSAttributedString{
        let mutString: NSMutableString = NSMutableString(string: self)
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: self)
        
        for bText in highlightedTextsArray{
            let range: NSRange = mutString.range(of: bText, options: .caseInsensitive)
            if range.length == 0{
                continue
            }
            
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: fontSize)]
            let boldAttrText = NSMutableAttributedString(string: bText, attributes: attrs)
            
            attributedString.replaceCharacters(in: range, with: boldAttrText)
        }
        
        return attributedString
    }
    
    var isEmail: Bool{
        let emailRegex = "^(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){255,})(?!(?:(?:\\x22?\\x5C[\\x00-\\x7E]\\x22?)|(?:\\x22?[^\\x5C\\x22]\\x22?)){65,}@)(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22))(?:\\.(?:(?:[\\x21\\x23-\\x27\\x2A\\x2B\\x2D\\x2F-\\x39\\x3D\\x3F\\x5E-\\x7E]+)|(?:\\x22(?:[\\x01-\\x08\\x0B\\x0C\\x0E-\\x1F\\x21\\x23-\\x5B\\x5D-\\x7F]|(?:\\x5C[\\x00-\\x7F]))*\\x22)))*@(?:(?:(?!.*[^.]{64,})(?:(?:(?:xn--)?[a-z0-9]+(?:-+[a-z0-9]+)*\\.){1,126}){1,}(?:(?:[a-z][a-z0-9]*)|(?:(?:xn--)[a-z0-9]+))(?:-+[a-z0-9]+)*)|(?:\\[(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){7})|(?:(?!(?:.*[a-f0-9][:\\]]){7,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,5})?)))|(?:(?:IPv6:(?:(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){5}:)|(?:(?!(?:.*[a-f0-9]:){5,})(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3})?::(?:[a-f0-9]{1,4}(?::[a-f0-9]{1,4}){0,3}:)?)))?(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))(?:\\.(?:(?:25[0-5])|(?:2[0-4][0-9])|(?:1[0-9]{2})|(?:[1-9]?[0-9]))){3}))\\]))$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
    
    func encode() -> String{
        let data = Data(self.utf8)
        let hashed = SHA256.hash(data: data)
        return hashed.description
    }

//    var containsOnlyDigits: Bool {
//        let notDigits = NSCharacterSet.decimalDigits.inverted
//        return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
//    }
//
//    var containsOnlyLetters: Bool {
//        let notLetters = NSCharacterSet.letters.inverted
//        return rangeOfCharacter(from: notLetters, options: String.CompareOptions.literal, range: nil) == nil
//    }
//
//    var isAlphanumeric: Bool {
//        let notAlphanumeric = NSCharacterSet.decimalDigits.union(NSCharacterSet.letters).inverted
//        return rangeOfCharacter(from: notAlphanumeric, options: String.CompareOptions.literal, range: nil) == nil
//    }
}

extension StringProtocol {
    var double: Double? { Double(self) }
    var float: Float? { Float(self) }
    var integer: Int? { Int(self) }
}
