//
//  WButtonSecondary.swift
//  UIComponents
//
//  Created by Sina on 3/31/23.
//

import UIKit

@IBDesignable
public class WButtonSecondary: UIButton {

    public static let defaultHeight = CGFloat(50)

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    public func setup() {
        // set height anchor as default value
        heightAnchor.constraint(equalToConstant: WButtonSecondary.defaultHeight).isActive = true
    }
}
