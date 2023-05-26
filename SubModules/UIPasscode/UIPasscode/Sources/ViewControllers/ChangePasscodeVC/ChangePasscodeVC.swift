//
//  ChangePasscodeVC.swift
//  UIPasscode
//
//  Created by Sina on 5/4/23.
//

import UIKit
import UIComponents
import WalletContext

public enum ChangePasscodeStep {
    case currentPasscode
    case newPasscode
    case verifyPasscode(passcode: String)
}

public class ChangePasscodeVC: WViewController {

    private let step: ChangePasscodeStep
    public init(step: ChangePasscodeStep) {
        self.step = step
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private var passcodeScreenView: PasscodeScreenView!

    private func setupViews() {
        let title: String
        switch step {
        case .currentPasscode:
            title = WStrings.Wallet_ChangePasscode_Title.localized
            
            // add back button
            let cancelButton = UIBarButtonItem(title: WStrings.Wallet_Navigation_Cancel.localized, style: .done, target: self, action: #selector(cancelPressed))
            navigationItem.leftBarButtonItem = cancelButton
            break
        case .newPasscode:
            title = WStrings.Wallet_ChangePasscode_NewPassTitle.localized
            break
        case .verifyPasscode(_):
            title = WStrings.Wallet_ChangePasscode_NewPassVerifyTitle.localized
        }
        passcodeScreenView = PasscodeScreenView(title: title,
                                                biometricPassAllowed: false,
                                                delegate: self)
        passcodeScreenView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(passcodeScreenView)
        NSLayoutConstraint.activate([
            passcodeScreenView.leftAnchor.constraint(equalTo: view.leftAnchor),
            passcodeScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            passcodeScreenView.rightAnchor.constraint(equalTo: view.rightAnchor),
            passcodeScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true)
    }
}

extension ChangePasscodeVC: PasscodeScreenViewDelegate {
    func passcodeChanged(passcode: String) {
    }
    
    func passcodeSelected(passcode: String) {
        switch step {
        case .currentPasscode:
            if passcode == KeychainHelper.passcode() {
                navigationController?.pushViewController(ChangePasscodeVC(step: .newPasscode), animated: true)
            } else {
                // TODO:: Error
            }
            passcodeScreenView.passcodeInputView.currentPasscode = ""
            break
        case .newPasscode:
            navigationController?.pushViewController(ChangePasscodeVC(step: .verifyPasscode(passcode: passcode)),
                                                     animated: true)
            passcodeScreenView.passcodeInputView.currentPasscode = ""
            break
        case let .verifyPasscode(currentPass):
            if passcode == currentPass {
                // set new passcode
                KeychainHelper.save(passcode: passcode)
                dismiss(animated: true)
            } else {
                // go back to get a passcode again
                passcodeScreenView.passcodeInputView.currentPasscode = ""
                navigationController?.popViewController(animated: true)
            }
            break
        }
    }
    
    func onAuthenticated() {
        
    }
}
