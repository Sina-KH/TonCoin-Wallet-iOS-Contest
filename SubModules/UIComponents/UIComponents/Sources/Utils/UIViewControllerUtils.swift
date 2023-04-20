//
//  UIViewControllerUtils.swift
//  UIComponents
//
//  Created by Sina on 4/13/23.
//

import UIKit

public extension UIViewController {
    
    // show alert view error message
    func showAlert(title: String, text: String,
                   button: String, buttonPressed: (() -> ())? = nil,
                   secondaryButton: String? = nil, secondaryButtonPressed: (() -> ())? = nil,
                   preferPrimary: Bool = true) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .alert)
        let primaryAction = UIAlertAction(title: button,
                                          style: .default,
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
        // TODO:: Actions stack view should fill one row per action
        present(alert, animated: true, completion: nil)
    }
}
