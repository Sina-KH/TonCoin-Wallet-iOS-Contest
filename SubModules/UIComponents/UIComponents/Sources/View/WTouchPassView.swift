//
//  WTouchPassView.swift
//  UIComponents
//
//  Created by Sina on 5/26/23.
//

import UIKit

open class WTouchPassView: UIView {
    // pass touch events to below view
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return nil
        } else {
            return hitView
        }
    }
}
