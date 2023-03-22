//
//  Bundle+Extension.swift
//  Trening
//
//  Created by Łukasz Cieślik on 17/03/2023.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
