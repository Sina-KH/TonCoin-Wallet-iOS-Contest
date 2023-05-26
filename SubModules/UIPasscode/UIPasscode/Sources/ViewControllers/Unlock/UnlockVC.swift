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

// Used for AppUnlock and other actions that require user to unlock using passcode or biometric, first.
public class UnlockVC: WViewController {
    
    // should be called before auth required actions (like `TON Connect 2` connection),
    //  For now, we don't use this VC for TON Transfers and Words Recovery, because they use iOS Unlock, to decrypt hardware encrypted private key.
    //  This function first, tries to unlock using biometric, if is activated and then, present this VC if failed.
    public static func presentAuth(on vc: UIViewController, onAuth: @escaping () -> Void, cancellable: Bool = false, onCancel: (() -> Void)? = nil) {

        func unlockVC() -> UIViewController {
            if cancellable {
                return UINavigationController(rootViewController: UnlockVC(onAuth: onAuth, cancellable: cancellable, onCancel: onCancel))
            } else {
                return UnlockVC(onAuth: onAuth, cancellable: cancellable, onCancel: onCancel)
            }
        }

        let context = LAContext()
        var error: NSError?
        if KeychainHelper.isBiometricActivated() && context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = WStrings.Wallet_Biometric_Reason.localized
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak vc] success, authenticationError in
                DispatchQueue.main.async { [weak vc] in
                    if success {
                        onAuth()
                    } else {
                        // error
                        vc?.present(unlockVC(), animated: true)
                    }
                }
            }
        } else {
            vc.present(unlockVC(), animated: true)
        }
    }
    
    private let animatedPresentation: Bool
    private let onAuthCallback: () -> Void
    private let cancellable: Bool
    private let onCancel: (() -> Void)?
    public init(animatedPresentation: Bool = false, onAuth: @escaping () -> Void, cancellable: Bool = false, onCancel: (() -> Void)? = nil) {
        self.animatedPresentation = animatedPresentation
        self.onAuthCallback = onAuth
        self.cancellable = cancellable
        self.onCancel = onCancel
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
        if cancellable {
            // add back button
            let cancelButton = UIBarButtonItem(title: WStrings.Wallet_Navigation_Cancel.localized, style: .done, target: self, action: #selector(cancelPressed))
            navigationItem.leftBarButtonItem = cancelButton
        }

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
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if animatedPresentation {
            view.backgroundColor = WTheme.balanceHeaderView.background
            passcodeScreenView.alpha = 0
            view.layoutIfNeeded()
            UIView.animate(withDuration: 0.2) {
                self.passcodeScreenView.alpha = 1
            }
        }
    }
    
    @objc func cancelPressed() {
        dismiss(animated: true) {
            self.onCancel?()
        }
    }

    // when this function is called, `UnlockVC` retries to use biometric
    public func tryBiometric() {
        passcodeScreenView.tryBiometric()
    }
}

extension UnlockVC: PasscodeScreenViewDelegate {
    func passcodeChanged(passcode: String) {
    }
    
    func passcodeSelected(passcode: String) {
        if passcode == KeychainHelper.passcode() {
            onAuthenticated()
        } else {
            passcodeScreenView.passcodeInputView.currentPasscode = ""
            AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) { }
        }
    }

    func onAuthenticated() {
        if animatedPresentation {
            UIView.animate(withDuration: 0.2, animations: {
                self.passcodeScreenView.alpha = 0
            }) { [weak self] _ in
                self?.dismiss(animated: false, completion: {
                    self?.onAuthCallback()
                })
            }
        } else {
            dismiss(animated: true) { [weak self] in
                self?.onAuthCallback()
            }
        }
    }
}
