//
//  WTheme.swift
//  WalletContext
//
//  Created by Sina on 4/14/23.
//

import UIKit

public struct WThemeBackgroundHeaderView {
    public var background: UIColor
    public var headIcons: UIColor
    public var balance: UIColor
}

public struct WThemePrimaryButton {
    public var background: UIColor
    public var tint: UIColor
    public var disabledBackground: UIColor
    public var disabledTint: UIColor
}

public struct WThemeAccentButton {
    public var background: UIColor
    public var tint: UIColor
}

public struct WThemeWordInput {
    public var background: UIColor
}

public struct WThemePasscodeInput {
    public var border: UIColor
    public var empty: UIColor
    public var fill: UIColor
}

public struct WThemeToastView {
    public var background: UIColor
    public var tint: UIColor
}

public struct WThemeType {
    public var primaryButton: WThemePrimaryButton
    public var accentButton: WThemeAccentButton
    public var wordInput: WThemeWordInput
    public var setPasscodeInput: WThemePasscodeInput
    public var unlockPasscodeInput: WThemePasscodeInput
    public var balanceHeaderView: WThemeBackgroundHeaderView
    public var toastView: WThemeToastView
    public var background: UIColor
    public var backgroundReverse: UIColor
    public var groupedBackground: UIColor
    public var primaryLabel: UIColor
    public var secondaryLabel: UIColor
    public var tertiaryLabel: UIColor
    public var border: UIColor
    public var separator: UIColor
    public var tint: UIColor
    public var positiveAmount: UIColor
    public var negativeAmount: UIColor
    public var warning: UIColor
    public var error: UIColor
}

// Current theme now supports both light and dark themes.

/* If we want to use default iOS colors on dark/light mode (like .systemBackground or just a single UIColor), we define colors in this file, otherwise,
    for custom colors, we define them in WColors and Assets */

/*  If we need to support more custom themes inside the app, and let user change it when using the app without restarting the app,
    `WTheme` variable should be changed real-time and the app should be configured to call all .updateTheme() methods on theme change event.
        (in that case, we have to make all views confirm to a protocol containing `updateTheme` method and call this method on all views and view controllers.)
        (and also, some components may need an update, to support this feature by updating all colors inside updateTheme method.) */

public var WTheme = WThemeType(
    primaryButton: WThemePrimaryButton(background: UIColor.systemBlue,
                                       tint: UIColor.white,
                                       disabledBackground: _groupedBackground,
                                       disabledTint: WColors.secondaryLabel.color),
    accentButton: WThemeAccentButton(background: _accent,
                                     tint: UIColor.white),
    wordInput: WThemeWordInput(background: WColors.secondaryBackground.color),
    setPasscodeInput: WThemePasscodeInput(border: _border, empty: _systemBackground, fill: _systemBackgroundReverse),
    unlockPasscodeInput: WThemePasscodeInput(border: .white, empty: .clear, fill: .white),
    balanceHeaderView: WThemeBackgroundHeaderView(background: .black, headIcons: .white, balance: .white),
    toastView: WThemeToastView(background: _systemBackgroundReverse.withAlphaComponent(0.82), tint: _systemBackground),
    background: _systemBackground,
    backgroundReverse: _systemBackgroundReverse,
    groupedBackground: _groupedBackground,
    primaryLabel: _systemBackgroundReverse,
    secondaryLabel: WColors.secondaryLabel.color,
    tertiaryLabel: _tertiaryLabel,
    border: _border,
    separator: WColors.separator.color,
    tint: .systemBlue,
    positiveAmount: .systemGreen,
    negativeAmount: .systemRed,
    warning: .systemOrange,
    error: .systemRed
)

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

fileprivate var _groupedBackground: UIColor {
    if #available(iOS 13.0, *) {
        return .systemGroupedBackground
    } else {
        return .groupTableViewBackground
    }
}

fileprivate var _border: UIColor {
    if #available(iOS 13.0, *) {
        return .separator
    } else {
        return UIColor(white: 0.23, alpha: 0.36)
    }
}

private var _accent: UIColor {
    return UIColor(red: 0.196, green: 0.667, blue: 0.996, alpha: 1)
}

private var _tertiaryLabel: UIColor {
    if #available(iOS 13.0, *) {
        return .tertiaryLabel
    } else {
        return UIColor.black.withAlphaComponent(0.3)
    }
}
