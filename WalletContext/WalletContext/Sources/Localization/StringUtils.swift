//
//  StringUtils.swift
//  UIComponents
//
//  Created by Sina on 4/14/23.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
