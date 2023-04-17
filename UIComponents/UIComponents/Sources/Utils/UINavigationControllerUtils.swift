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

}
