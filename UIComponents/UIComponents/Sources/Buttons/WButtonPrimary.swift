//
//  WButtonPrimary.swift
//  UIComponents
//
//  Created by Sina on 3/30/23.
//

import UIKit

fileprivate let _borderRadius = 12.0
fileprivate let _height = 50.0
fileprivate let _font = UIFont.systemFont(ofSize: 17, weight: .semibold)

@IBDesignable
class WButtonPrimary: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup(interfaceBuilder: true)
    }
    
    func setup(interfaceBuilder: Bool = false) {
        // disable default styling of iOS 15+ to prevent tint/font set conflict issues
        if #available(iOS 15.0, *) {
            // setting configuration to .none on interface builder makes text disappear
            if !interfaceBuilder {
                configuration = .none
            }
        }
        // set background color
        backgroundColor = .systemBlue
        // set title color
        tintColor = .white
        // set corner radius
        layer.cornerRadius = _borderRadius
        // set height anchor as default value
        heightAnchor.constraint(equalToConstant: _height).isActive = true
        // set font
        titleLabel?.font = _font
    }
}
