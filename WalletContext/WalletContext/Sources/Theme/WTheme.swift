//
//  WTheme.swift
//  WalletContext
//
//  Created by Sina on 4/14/23.
//

import UIKit

public struct WThemePrimaryButton {
    public var background: UIColor
    public var tint: UIColor
}

public struct WTheme {
    public var background: UIColor
    public var primaryButton: WThemePrimaryButton
    public var secondaryLabel: UIColor
}

// Current theme now supports both light and dark themes.
//  If we need to support more themes, this variable should be changed and the app should be configured to call all .updateTheme() methods. (some components may need an update, to support this feature)
public var currentTheme = WTheme(
    background: _systemBackground,
    primaryButton: WThemePrimaryButton(background: UIColor.systemBlue, tint: UIColor.white),
    secondaryLabel: WColors.secondaryLabel.color
)

fileprivate var _systemBackground: UIColor {
    if #available(iOS 13.0, *) {
        return .systemBackground
    } else {
        return .white
    }
}
