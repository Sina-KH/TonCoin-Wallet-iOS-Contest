//
//  SecuritySettingsChangedVC.swift
//  UICreateWallet
//
//  Created by Sina on 5/12/23.
//

import UIKit
import SwiftSignalKit
import WalletCore
import UIPasscode
import UIComponents
import WalletContext

public enum SecuritySettingsChangedType {
    case notAvailable
    case changed
}

public class SecuritySettingsChangedVC: WViewController {

    private let walletContext: WalletContext
    private let changeType: SecuritySettingsChangedType

    public init(walletContext: WalletContext, changeType: SecuritySettingsChangedType) {
        self.walletContext = walletContext
        self.changeType = changeType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }
    
    private var bottomActionsView: BottomActionsView!

    func setupViews() {
        
        if changeType == .changed {
            
            let enterWordsButton = BottomAction(
                title: WStrings.Wallet_SecuritySettingsChanged_ImportWallet.localized,
                onPress: {
                    self.navigationController?.pushViewController(ImportWalletVC(walletContext: self.walletContext), animated: true)
                }
            )
            
            let createWalletButton = BottomAction(
                title: WStrings.Wallet_SecuritySettingsChanged_CreateWallet.localized,
                onPress: {
                    self.createWalletPressed()
                }
            )

            bottomActionsView = BottomActionsView(primaryAction: enterWordsButton,
                                                  secondaryAction: createWalletButton)
        } else {
            bottomActionsView = BottomActionsView(primaryAction: BottomAction(title: WStrings.Wallet_Alert_OK.localized, onPress: {
                self.walletContext.restartApp()
            }))
        }
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

        let biometricString: String?
        switch BiometricHelper.biometricType() {
        case .face:
            biometricString = WStrings.Wallet_SecuritySettingsChanged_BiometryFaceID.localized
            break
        case .none:
            biometricString = WStrings.Wallet_SecuritySettingsChanged_BiometryTouchID.localized
            break
        case .touch:
            biometricString = nil
            break
        }
        let description: String
        switch changeType {
        case .notAvailable:
            description = biometricString == nil ?
                WStrings.Wallet_SecuritySettingsChanged_ResetPasscodeText.localized :
                WStrings.Wallet_SecuritySettingsChanged_ResetBiometryText(biometricType: biometricString!)
            break
        case .changed:
            description = biometricString == nil ?
                WStrings.Wallet_SecuritySettingsChanged_PasscodeText.localized :
                WStrings.Wallet_SecuritySettingsChanged_BiometryText(biometricType: biometricString!)
            break
        }

        let headerView = HeaderView(animationName: "Too Bad",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_SecuritySettingsChanged_Title.localized,
                                    description: description)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    var isLoading = false {
        didSet {
            bottomActionsView.secondaryButton.showLoading = isLoading
            view.isUserInteractionEnabled = !isLoading
        }
    }
    func createWalletPressed() {
        if isLoading {
            return
        }
        isLoading = true

        let _ = (walletContext.getServerSalt()
        |> deliverOnMainQueue).start(next: { [weak self] serverSalt in
            guard let self else {
                return
            }
            let _ = (createWallet(storage: walletContext.storage,
                                  tonInstance: walletContext.tonInstance,
                                  keychain: walletContext.keychain,
                                  localPassword: serverSalt)
            |> deliverOnMainQueue).start(next: { [weak self] walletInfo, wordList in
                guard let self else { return }

                let walletCreatedVC = WalletCreatedVC(walletContext: walletContext,
                                                      walletInfo: walletInfo,
                                                      wordList: wordList)
                navigationController?.pushViewController(walletCreatedVC, animated: true)
                isLoading = false

            }, error: { [weak self] _ in
                guard let self else  { return }
                showAlert()
                isLoading = false
            })
        }, error: { [weak self] _ in
            guard let self else  { return }
            showAlert()
            isLoading = false
        })
    }
    
    func importWalletPressed() {
        navigationController?.pushViewController(ImportWalletVC(walletContext: walletContext), animated: true)
    }
    
    func showAlert() {
        showAlert(title: WStrings.Wallet_Intro_CreateErrorTitle.localized,
                  text: WStrings.Wallet_Intro_CreateErrorText.localized,
                  button: WStrings.Wallet_Alert_OK.localized)
    }
}
