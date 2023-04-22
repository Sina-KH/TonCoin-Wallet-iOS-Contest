//
//  EmptyWalletView.swift
//  UIWalletHome
//
//  Created by Sina on 4/21/23.
//

import UIKit
import UIComponents
import WalletContext

public class EmptyWalletView: UIView {
        
    public init() {
        super.init(frame: CGRect.zero)
        setupView()
    }

    override public init(frame: CGRect) {
        fatalError()
    }
    
    required public init?(coder: NSCoder) {
        fatalError()
    }

    var loadingView: WalletLoadingView!

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        // loading wallet view
        loadingView = WalletLoadingView()
        addSubview(loadingView)
        let centerYConstraint = loadingView.centerYAnchor.constraint(equalTo: centerYAnchor)
        centerYConstraint.priority = UILayoutPriority(750)
        NSLayoutConstraint.activate([
            loadingView.leftAnchor.constraint(equalTo: leftAnchor),
            loadingView.rightAnchor.constraint(equalTo: rightAnchor),
            centerYConstraint
        ])
    }
    
    // switch from loading to wallet created animation and wallet address
    public func showWalletCreatedView(address: String) {
        if loadingView.alpha == 0 {
            return
        }

        // created wallet view
        let walletCreatedView = WalletCreatedView(address: address)
        walletCreatedView.alpha = 0
        addSubview(walletCreatedView)
        NSLayoutConstraint.activate([
            walletCreatedView.leftAnchor.constraint(equalTo: leftAnchor),
            walletCreatedView.rightAnchor.constraint(equalTo: rightAnchor),
            walletCreatedView.topAnchor.constraint(equalTo: loadingView.topAnchor)
        ])
        layoutIfNeeded()

        // by activating centerYConstraint on wallet created view, it will make loading view come up with it, animated.
        let centerYConstraint = walletCreatedView.centerYAnchor.constraint(equalTo: centerYAnchor)
        UIView.animate(withDuration: 0.4) {
            centerYConstraint.isActive = true
            self.loadingView.alpha = 0
            walletCreatedView.alpha = 1
            self.layoutIfNeeded()
        }
    }
    
    // hide view
    public func hideAnimated() {
        UIView.animate(withDuration: 0.4, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 100)
            self.alpha = 0
            self.layoutIfNeeded()
        }) { finished in
            self.removeFromSuperview()
        }
    }

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
