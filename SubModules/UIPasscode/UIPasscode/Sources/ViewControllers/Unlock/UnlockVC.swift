//
//  UnlockVC.swift
//  UIPasscode
//
//  Created by Sina on 4/28/23.
//

import UIKit
import UIComponents
import WalletContext
import LocalAuthentication
import AVFoundation

public class UnlockVC: WViewController {
    
    public static func presentAuth(on vc: UIViewController, onAuth: @escaping () -> Void) {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = WStrings.Wallet_Biometric_Reason.localized
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak vc] success, authenticationError in
                DispatchQueue.main.async { [weak vc] in
                    if success {
                        onAuth()
                    } else {
                        // error
                        vc?.present(UnlockVC(onAuth: onAuth), animated: true)
                    }
                }
            }
        } else {
            vc.present(UnlockVC(onAuth: onAuth), animated: true)
        }
    }
    
    private var onAuthCallback: () -> Void
    public init(onAuth: @escaping () -> Void) {
        self.onAuthCallback = onAuth
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
        passcodeScreenView = PasscodeScreenView(title: WStrings.Wallet_Unlock_Title.localized,
                                                biometricPassAllowed: KeychainHelper.isBiometricActivated(),
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
}

extension UnlockVC: PasscodeScreenViewDelegate {
    func passcodeChanged(passcode: String) {
    }
    
    func passcodeSelected(passcode: String) {
        if passcode == KeychainHelper.passcode() {
            dismiss(animated: true) { [weak self] in
                self?.onAuth()
            }
        } else {
            passcodeScreenView.passcodeInputView.currentPasscode = ""
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        }
    }
    
    func onAuth() {
        onAuthCallback()
    }
}
