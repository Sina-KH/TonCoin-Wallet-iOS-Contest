//
//  WButton.swift
//  UIComponents
//
//  Created by Sina on 3/30/23.
//

import UIKit
import WalletContext

fileprivate let _borderRadius = 12.0
fileprivate let _font = UIFont.systemFont(ofSize: 17, weight: .semibold)

@IBDesignable
public class WButton: UIButton {

    public static let defaultHeight = CGFloat(50.0)

    public enum Usage {
        case primary
        case secondary
        case accent
    }

    private var usage = Usage.primary

    // used factory pattern because can't subclass a button and call `super.init(buttonType: )`,
    //  if we have an initializer in our subclass, we will loose that initializer ! :)
    public static func setupInstance(_ usage: WButton.Usage = .primary,
                                     buttonType: UIButton.ButtonType = .system) -> WButton {
        let primaryButton = WButton(type: buttonType)
        primaryButton.usage = usage
        primaryButton.setup()
        return primaryButton
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup(interfaceBuilder: true)
    }
    
    private func setup(interfaceBuilder: Bool = false) {
        // disable default styling of iOS 15+ to prevent tint/font set conflict issues
        if #available(iOS 15.0, *) {
            // setting configuration to .none on interface builder makes text disappear
            if !interfaceBuilder {
                configuration = .none
            }
        }
        // set corner radius
        layer.cornerRadius = _borderRadius
        // set height anchor as default value
        heightAnchor.constraint(equalToConstant: WButton.defaultHeight).isActive = true
        // set font
        titleLabel?.font = _font
        
        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
        switch usage {
        case .primary:
            backgroundColor = currentTheme.primaryButton.background
            tintColor = currentTheme.primaryButton.tint
            break
        case .accent:
            backgroundColor = currentTheme.accentButton.background
            tintColor = currentTheme.accentButton.tint
            break
        default:
            break
        }
    }

    // used to place a gap between the image and text
    public func centerTextAndImage(spacing: CGFloat) {
        let insetAmount = spacing / 2
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
           imageEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
           titleEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
           contentEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: -insetAmount)
        } else {
           imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
           titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
           contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}
