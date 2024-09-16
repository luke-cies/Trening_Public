//
//  DateExtension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 05/06/2024.
//

import Foundation

extension Date {
    func getString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        return formatter.string(from: self)
    }
}
