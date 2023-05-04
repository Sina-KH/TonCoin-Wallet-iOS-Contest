//
//  SettingsVM.swift
//  UIWalletHome
//
//  Created by Sina on 5/4/23.
//

import Foundation
import LocalAuthentication
import WalletCore
import WalletContext
import SwiftSignalKit

protocol SettingsVMDelegate: AnyObject {
    func showRecoveryPhrase(wordList: [String])
    func biometricUpdated(to: Bool)
    func biometricActivationErrorOccured()
}

class SettingsVM {
    
    weak var settingsVMDelegate: SettingsVMDelegate?
    init(settingsVMDelegate: SettingsVMDelegate) {
        self.settingsVMDelegate = settingsVMDelegate
    }
    
    // MARK: - Recovery Phrase
    func loadRecoveryPhrase(walletContext: WalletContext, walletInfo: WalletInfo) {
        let _ = (walletContext.keychain.decrypt(walletInfo.encryptedSecret)
        |> deliverOnMainQueue).start(next: { [weak self] decryptedSecret in
            let _ = (walletContext.getServerSalt()
            |> deliverOnMainQueue).start(next: { serverSalt in
                let _ = (walletRestoreWords(tonInstance: walletContext.tonInstance,
                                            publicKey: walletInfo.publicKey,
                                            decryptedSecret: decryptedSecret,
                                            localPassword: serverSalt)
                |> deliverOnMainQueue).start(next: { [weak self] wordList in
                    self?.settingsVMDelegate?.showRecoveryPhrase(wordList: wordList)
                    }, error: { _ in
                })
            }, error: { _ in
            })
        }, error: { _ in
        })
    }

    // MARK: - Biometric Settings
    var isBiometricActivated: Bool {
        return KeychainHelper.isBiometricActivated()
    }

    func activateBiometric() {
        let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = WStrings.Wallet_Biometric_Reason.localized

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async { [weak self] in
                        if success {
                            self?.setBiometric(activated: true)
                        } else {
                            self?.settingsVMDelegate?.biometricUpdated(to: false)
                        }
                    }
                }
            } else {
                settingsVMDelegate?.biometricActivationErrorOccured()
            }
    }
    
    func disableBiometric() {
        setBiometric(activated: false)
    }
    
    private func setBiometric(activated: Bool) {
        KeychainHelper.save(biometric: activated)
        settingsVMDelegate?.biometricUpdated(to: activated)
    }
}
