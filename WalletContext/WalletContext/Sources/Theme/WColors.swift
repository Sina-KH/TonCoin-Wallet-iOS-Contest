//
//  WColors.swift
//  WalletContext
//
//  Created by Sina on 4/14/23.
//

import UIKit

enum WColors: String {
    case secondaryLabel = "SecondaryLabel"

    var color: UIColor {
        return UIColor(named: rawValue)!
    }
}
