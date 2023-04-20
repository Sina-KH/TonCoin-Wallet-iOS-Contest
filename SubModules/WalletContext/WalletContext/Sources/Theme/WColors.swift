//
//  WColors.swift
//  WalletContext
//
//  Created by Sina on 4/14/23.
//

import UIKit

// for colors, that are used in the Themes, but are not standard iOS Colors, we define them here and add them to ColorSets in the assets.
enum WColors: String {
    case secondaryLabel = "SecondaryLabel"
    case secondaryBackground = "SecondaryBackground"
    case separator = "Separator"

    var color: UIColor {
        return UIColor(named: rawValue)!
    }
}
