//
//  WKeyboardObserver.swift
//  UIComponents
//
//  Created by Sina on 4/15/23.
//

import UIKit

public protocol WKeyboardObserverDelegate: AnyObject {
    func keyboardDidShow(height: CGFloat)
    func keyboardDidHide()
}

public class WKeyboardObserver {
    
    private weak var delegate: WKeyboardObserverDelegate?
    
    public static func observeKeyboard(delegate: WKeyboardObserverDelegate) {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                               object: nil,
                                               queue: nil) { [weak delegate] notification in
            guard let info = notification.userInfo else { return }
            guard let frameInfo = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            let keyboardFrame = frameInfo.cgRectValue
            delegate?.keyboardDidShow(height: keyboardFrame.height)
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification,
                                               object: nil,
                                               queue: nil) { [weak delegate] notification in
            delegate?.keyboardDidHide()
        }
    }
}
