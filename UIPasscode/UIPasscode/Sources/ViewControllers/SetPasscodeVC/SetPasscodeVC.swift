//
//  SetPasscodeVC.swift
//  UIPasscode
//
//  Created by Sina on 4/16/23.
//

import UIKit
import UIComponents
import WalletContext

public class SetPasscodeVC: WViewController {

    var passcodeInputView: PasscodeInputView!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    func setupViews() {
        // setup passcode input view
        passcodeInputView = PasscodeInputView(delegate: self)
        passcodeInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeInputView)
        NSLayoutConstraint.activate([
            passcodeInputView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passcodeInputView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        passcodeInputView.becomeFirstResponder()
    }

}

extension SetPasscodeVC: PasscodeInputViewDelegate {
    func passcodeSelected(passcode: String) {
        // TODO::
    }
}
