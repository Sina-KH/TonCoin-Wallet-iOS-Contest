//
//  UIViewControllerUtils.swift
//  UIComponents
//
//  Created by Sina on 4/13/23.
//

import UIKit

public extension UIViewController {
    
    fileprivate func alert(title: String?, text: String,
                           button: String, buttonStyle: UIAlertAction.Style, buttonPressed: (() -> ())? = nil,
                           secondaryButton: String? = nil, secondaryButtonPressed: (() -> ())? = nil,
                           preferPrimary: Bool = true) -> UIAlertController {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let primaryAction = UIAlertAction(title: button,
                                          style: buttonStyle,
                                          handler: {(alert: UIAlertAction!) in
            buttonPressed?()
        }
        )
        alert.addAction(primaryAction)
        if let secondaryButton {
            alert.addAction(UIAlertAction(title: secondaryButton,
                                          style: .default,
                                          handler: {(alert: UIAlertAction!) in
                secondaryButtonPressed?()
            })
            )
        }
        if preferPrimary {
            alert.preferredAction = primaryAction
        }

        return alert
    }
    
    // show attributed string alert view error message
    func showAlert(title: String?, textAttr: NSAttributedString,
                   button: String, buttonPressed: (() -> ())? = nil, buttonStyle: UIAlertAction.Style = .default,
                   secondaryButton: String? = nil, secondaryButtonPressed: (() -> ())? = nil,
                   preferPrimary: Bool = true) {
        let alert = alert(
            title: title,
            text: " ",
            button: button,
            buttonStyle: buttonStyle,
            buttonPressed: buttonPressed,
            secondaryButton: secondaryButton,
            secondaryButtonPressed: secondaryButtonPressed,
            preferPrimary: preferPrimary
        )
        alert.setValue(textAttr, forKey: "attributedMessage")
        present(alert, animated: true, completion: nil)
    }
    
    // show alert view error message
    func showAlert(title: String?, text: String,
                   button: String, buttonStyle: UIAlertAction.Style = .default, buttonPressed: (() -> ())? = nil,
                   secondaryButton: String? = nil, secondaryButtonPressed: (() -> ())? = nil,
                   preferPrimary: Bool = true) {
        let alert = alert(
            title: title,
            text: text,
            button: button,
            buttonStyle: buttonStyle,
            buttonPressed: buttonPressed,
            secondaryButton: secondaryButton,
            secondaryButtonPressed: secondaryButtonPressed,
            preferPrimary: preferPrimary
        )
        // TODO:: Actions stack view should fill one row per action
        present(alert, animated: true, completion: nil)
    }
}
