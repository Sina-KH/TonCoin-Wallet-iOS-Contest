//
//  WButtonPrimary.swift
//  UIComponents
//
//  Created by Sina on 3/30/23.
//

import UIKit
import WalletContext

fileprivate let _borderRadius = 12.0
fileprivate let _height = 50.0
fileprivate let _font = UIFont.systemFont(ofSize: 17, weight: .semibold)

@IBDesignable
public class WButtonPrimary: UIButton {

    public override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup(interfaceBuilder: true)
    }
    
    public func setup(interfaceBuilder: Bool = false) {
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
        heightAnchor.constraint(equalToConstant: _height).isActive = true
        // set font
        titleLabel?.font = _font
        
        // set theme colors
        updateTheme()
    }
    
    func updateTheme() {
        // set background color
        backgroundColor = currentTheme.primaryButton.background
        // set title color
        tintColor = currentTheme.primaryButton.tint
    }
}
