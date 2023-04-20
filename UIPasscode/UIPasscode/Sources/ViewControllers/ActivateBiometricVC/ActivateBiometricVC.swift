//
//  ActivateBiometricVC.swift
//  UIPasscode
//
//  Created by Sina on 4/18/23.
//

import UIKit
import UIComponents
import WalletContext
import WalletCore
import LocalAuthentication
import UIWalletHome

public class ActivateBiometricVC: WViewController {
    
    var walletContext: WalletContext
    var walletInfo: WalletInfo
    var onCompletion: () -> Void
    var selectedPasscode: String

    public init(walletContext: WalletContext,
                walletInfo: WalletInfo,
                onCompletion: @escaping () -> Void,
                selectedPasscode: String) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.onCompletion = onCompletion
        self.selectedPasscode = selectedPasscode
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var headerView: HeaderView!
    var passcodeInputView: PasscodeInputView!
    var passcodeOptionsView: PasscodeOptionsView!
    var bottomConstraint: NSLayoutConstraint!
    
    public static let passcodeOptionsFromBottom = CGFloat(8)
    
    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    func setupViews() {
        let biometricType = BiometricHelper.biometricType()
        
        let topImage: UIImage
        let titleString, descriptionString, enableString, skipString: String
        if biometricType == .face {
            topImage = UIImage(named: "FaceIDIcon")!
            titleString = WStrings.Wallet_Biometric_FaceID_Title.localized
            descriptionString = WStrings.Wallet_Biometric_TouchID_Text.localized
            enableString = WStrings.Wallet_Biometric_FaceID_Enable.localized
            skipString = WStrings.Wallet_Biometric_FaceID_Skip.localized
        } else {
            topImage = UIImage(named: "TouchIDIcon")!
            titleString = WStrings.Wallet_Biometric_TouchID_Title.localized
            descriptionString = WStrings.Wallet_Biometric_TouchID_Text.localized
            enableString = WStrings.Wallet_Biometric_TouchID_Enable.localized
            skipString = WStrings.Wallet_Biometric_TouchID_Skip.localized
        }

        let enableButtonAction = BottomAction(
            title: enableString,
            onPress: { [weak self] in
                self?.activateBiometricPressed()
            }
        )
        
        let skipButtonAction = BottomAction(
            title: skipString,
            onPress: { [weak self] in
                self?.finalizeFlow(biometricActivated: false)
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: enableButtonAction,
                                                  secondaryAction: skipButtonAction)
        view.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58),
            bottomActionsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])
        
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topView.bottomAnchor.constraint(equalTo: bottomActionsView.topAnchor)
        ])

        let headerView = HeaderView(icon: topImage,
                                    iconWidth: 124, iconHeight: 124,
                                    iconTintColor: currentTheme.tint,
                                    title: titleString,
                                    description: descriptionString)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }
    
    func activateBiometricPressed() {
        let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = WStrings.Wallet_Biometric_Reason.localized

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async { [weak self] in
                        if success {
                            self?.finalizeFlow(biometricActivated: true)
                        } else {
                            // error
                        }
                    }
                }
            } else {
                showAlert(title: WStrings.Wallet_Biometric_NotAvailableTitle.localized,
                          text: WStrings.Wallet_Biometric_NotAvailableText.localized,
                          button: WStrings.Wallet_Alert_OK.localized)
            }
    }
    
    func finalizeFlow(biometricActivated: Bool) {
        KeychainHelper.save(passcode: selectedPasscode)
        KeychainHelper.save(biometric: biometricActivated)
        onCompletion()
    }
}
