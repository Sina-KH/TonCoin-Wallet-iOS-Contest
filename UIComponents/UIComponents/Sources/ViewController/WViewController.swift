//
//  WViewController.swift
//  UIComponents
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletContext

open class WViewController: UIViewController {

    // set a view with background as UIViewController view, to do the rest, programmatically, inside the subclasses.
    open override func loadView() {
        let view = UIView()
        view.backgroundColor = currentTheme.background
        self.view = view
    }
}
