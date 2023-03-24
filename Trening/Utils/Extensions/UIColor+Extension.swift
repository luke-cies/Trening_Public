//
//  UIColor+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 13/03/2023.
//

import Foundation
import UIKit

extension UIColor{
    //MARK: - Properties
    static var TBlack: UIColor{
        .dynamicColor(lightMode: .black, darkMode: .white)
    }
    
    static var TBlackText: UIColor{
        .dynamicColor(lightMode: .black, darkMode: .white)
    }
    
    static var TWhite: UIColor{
        .dynamicColor(lightMode: .white, darkMode: .black)
    }
    
    static var TWhiteText: UIColor{
        .dynamicColor(lightMode: .white, darkMode: .black)
    }
    
    static var TDarkGray: UIColor{
        .dynamicColor(lightMode: .darkGray, darkMode: .darkGray)
    }
    
    static var TButtonGray: UIColor{
        .dynamicColor(lightMode: .color(55, 55, 55, 1), darkMode: .color(55, 55, 55, 1))
    }
    
    static var TButtonGrayInactive: UIColor{
        .dynamicColor(lightMode: .color(121, 121, 121, 1), darkMode: .color(121, 121, 121, 1))
    }
    
    static var TDarkBlue: UIColor{
        .dynamicColor(lightMode: .color(0, 36, 98, 1.0), darkMode: .color(0, 36, 98, 1.0))
    }
    
    static var TLineGray: UIColor{
        .dynamicColor(lightMode: .lightGray, darkMode: .lightGray)
    }
    
    static var TTableViewBackground: UIColor{
        .dynamicColor(lightMode: .TDarkGray, darkMode: .TDarkGray)
    }
    
    //MARK: - Public
    static func dynamicColor(lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
        
        return UIColor { (traitCollection) -> UIColor in
            return traitCollection.userInterfaceStyle == .light ? lightMode : darkMode
        }
    }
    
    //MARK: - Private
    private static func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor{
        return UIColor(red: (red / 255.0), green: (green / 255.0), blue: (blue / 255.0), alpha: alpha)
    }
}
