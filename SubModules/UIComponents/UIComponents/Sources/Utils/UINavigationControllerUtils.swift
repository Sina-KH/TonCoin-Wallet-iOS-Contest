//
//  UINavigationControllerUtils.swift
//  UIComponents
//
//  Created by Sina on 4/18/23.
//

import UIKit

extension UINavigationController {

    public func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        pushViewController(viewController, animated: animated)
        CATransaction.commit()
    }

    public func pushViewController(_ viewController: UIViewController,
                                   animated: Bool,
                                   clearStack: Bool) {
        pushViewController(viewController, animated: animated) { [weak self] in
            guard let self else {return}
            viewControllers = [viewControllers[viewControllers.count - 1]]
        }
    }
}