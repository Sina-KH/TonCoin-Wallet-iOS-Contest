//
//  WButtonSecondary.swift
//  UIComponents
//
//  Created by Sina on 3/31/23.
//

import UIKit

fileprivate let _height = 50.0

@IBDesignable
class WButtonSecondary: UIButton {

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    func setup() {
        // set height anchor as default value
        heightAnchor.constraint(equalToConstant: _height).isActive = true
    }
}
