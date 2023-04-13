//
//  UIViewUtils.swift
//  UIComponents
//
//  Created by Sina on 4/13/23.
//

import UIKit

public extension UIView {
    static func animationDurationFactor() -> Double {
        return animationDurationFactorImpl
    }
}

public func makeSpringAnimation(_ keyPath: String) -> CABasicAnimation {
    return makeSpringAnimationImpl(keyPath)
}
