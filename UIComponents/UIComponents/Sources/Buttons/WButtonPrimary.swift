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

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func setup() {
        // set colors
        backgroundColor = .systemBlue
        titleLabel?.textColor = UIColor.white
        // set corner radius
        layer.cornerRadius = _borderRadius
        // set height anchor as default value
        heightAnchor.constraint(equalToConstant: _height).isActive = true
        // set font
        titleLabel?.font = _font
    }
}
