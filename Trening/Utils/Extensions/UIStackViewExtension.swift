//
//  UIStackViewExtension.swift
//  FSStatsGrab
//
//  Created by Łukasz Cieślik on 30/05/2022.
//  Copyright © 2022 Rafal Michnik. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    
    /// convenience init for stack view. should be use as lazy var
    /// - Parameters:
    ///   - axis: default horizontal
    ///   - alignment: default fill
    ///   - distribution: default fill
    ///   - spacing: default nil
    ///   - translatesAutoresizingMaskIntoConstraints: default false
    ///   - subviews: suviews
    convenience init(axis: NSLayoutConstraint.Axis = .horizontal,
                     alignment: UIStackView.Alignment = .fill,
                     distribution: UIStackView.Distribution = .fill,
                     spacing: CGFloat? = nil,
                     translatesAutoresizingMaskIntoConstraints: Bool = false,
                     subviews: [UIView]) {
        
        self.init(frame: .zero)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        if let spacing = spacing {
            self.spacing = spacing
        }
        self.translatesAutoresizingMaskIntoConstraints = translatesAutoresizingMaskIntoConstraints
        subviews.forEach({ addArrangedSubview($0) })
    }
    
}
