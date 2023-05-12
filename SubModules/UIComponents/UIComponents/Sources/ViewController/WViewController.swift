//
//  WViewController.swift
//  UIComponents
//
//  Created by Sina on 4/14/23.
//

import UIKit
import WalletContext

open class WViewController: UIViewController {

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // set a view with background as UIViewController view, to do the rest, programmatically, inside the subclasses.
    open override func loadView() {
        let view = UIView()
        view.backgroundColor = WTheme.background
        self.view = view
    }
    
    // MARK: - BottomSheet Presentation and It's overaly view
    // present a view controller as bottom sheet using `WBottomSheetViewController`
    var overlayView: UIView? = nil
    open func present(bottomSheet: UIViewController) {
        if overlayView == nil {
            overlayView = UIView()
            overlayView?.translatesAutoresizingMaskIntoConstraints = false
            overlayView?.backgroundColor = .black.withAlphaComponent(0.32)
            overlayView?.alpha = 0
            view.addSubview(overlayView!)
            NSLayoutConstraint.activate([
                overlayView!.leftAnchor.constraint(equalTo: view.leftAnchor),
                overlayView!.topAnchor.constraint(equalTo: view.topAnchor),
                overlayView!.rightAnchor.constraint(equalTo: view.rightAnchor),
                overlayView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        // overlay view
        UIView.animate(withDuration: 0.5) {
            self.overlayView?.alpha = 1
        }
        present(WBottomSheetViewController(contentViewController: bottomSheet, delegate: self), animated: true)
    }
    func modalWillAppear() {
        if overlayView != nil {
            UIView.animate(withDuration: 0.5) {
                self.overlayView?.alpha = 1
            }
        }
    }
    func modalWillDisappear() {
        if overlayView != nil {
            UIView.animate(withDuration: 0.5, delay: 0, options: UIView.AnimationOptions.allowUserInteraction) {
                self.overlayView?.alpha = 0
            }
        }
    }
}
