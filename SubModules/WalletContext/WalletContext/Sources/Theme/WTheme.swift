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

public struct WThemeWordInput {
    public var background: UIColor
}

public struct WTheme {
    public var background: UIColor
    public var backgroundReverse: UIColor
    public var primaryButton: WThemePrimaryButton
    public var wordInput: WThemeWordInput
    public var primaryLabel: UIColor
    public var secondaryLabel: UIColor
    public var border: UIColor
    public var separator: UIColor
    public var tint: UIColor
}

// Current theme now supports both light and dark themes.
//  If we need to support more themes, `currentTheme` variable should be changed real-time and the app should be configured to call all .updateTheme() methods on theme change. (some components may need an update, to support this feature)
public var currentTheme = WTheme(
    background: _systemBackground,
    backgroundReverse: _systemBackgroundReverse,
    primaryButton: WThemePrimaryButton(background: UIColor.systemBlue, tint: UIColor.white),
    wordInput: WThemeWordInput(background: WColors.secondaryBackground.color),
    primaryLabel: _systemBackgroundReverse,
    secondaryLabel: WColors.secondaryLabel.color,
    border: _border,
    separator: WColors.separator.color,
    tint: .systemBlue
)

// if we want to use default iOS colors on dark/light mode, we define colors here, otherwise, for custom colors, we define then in WColors

fileprivate var _systemBackground: UIColor {
    if #available(iOS 13.0, *) {
        return .systemBackground
    } else {
        return .white
    }
}

fileprivate var _systemBackgroundReverse: UIColor {
    if #available(iOS 13.0, *) {
        return .label
    } else {
        return .black
    }
}

fileprivate var _border: UIColor {
    if #available(iOS 13.0, *) {
        return .separator
    } else {
        return UIColor(white: 0.23, alpha: 0.36)
    }
}
