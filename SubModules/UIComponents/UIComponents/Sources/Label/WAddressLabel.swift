//
//  WAddressLabel.swift
//  UIComponents
//
//  Created by Sina on 5/10/23.
//

import UIKit
import WalletContext

public class WAddressLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    private func setupView() {
        self.isUserInteractionEnabled = true
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(self.showMenu))
        self.addGestureRecognizer(gesture)
    }

    @objc func showMenu(_ recognizer: UILongPressGestureRecognizer) {
        self.becomeFirstResponder()
    
        let menu = UIMenuController.shared
    
        let locationOfTouchInLabel = recognizer.location(in: self)

        if !menu.isMenuVisible {
            var rect = bounds
            rect.origin = locationOfTouchInLabel
            rect.size = CGSize(width: 1, height: 1)
        
            menu.setTargetRect(frame, in: superview!)
            menu.setMenuVisible(true, animated: true)
        }
    }

    public var address: String = "" {
        didSet {
            text = formatAddress(address)
        }
    }
    
    public override func copy(_ sender: Any?) {
        let board = UIPasteboard.general
        board.string = address
        let menu = UIMenuController.shared
        menu.setMenuVisible(false, animated: true)
    }

    public override var canBecomeFirstResponder: Bool {
        return true
    }

    public override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.copy)
    }
}
