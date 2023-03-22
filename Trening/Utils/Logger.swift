//
//  Logger.swift
//  Trening
//
//  Created by Łukasz Cieślik on 15/03/2023.
//

import Foundation


struct Logger{
    static func log(_ message: String){
        print("Trening Log: \(message)")
    }
    
    static func error(_ message: String){
        print("===== Trening Error ===== \n \(message)")
    }
}
