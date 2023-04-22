//
//  RestoreFailedVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/21/23.
//

import UIKit
import SwiftSignalKit
import WalletCore
import UIComponents
import WalletContext

public class RestoreFailedVC: WViewController {

    var walletContext: WalletContext

    public init(walletContext: WalletContext) {
        self.walletContext = walletContext
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
        let enterWordsButton = BottomAction(
            title: WStrings.Wallet_RestoreFailed_EnterWords.localized,
            onPress: {
                self.navigationController?.popViewController(animated: true)
            }
        )
        
        let createWalletButton = BottomAction(
            title: WStrings.Wallet_RestoreFailed_CreateWallet.localized,
            onPress: {
                self.createWalletPressed()
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: enterWordsButton,
                                                  secondaryAction: createWalletButton)
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

        let headerView = HeaderView(animationName: "Too Bad",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_RestoreFailed_Title.localized,
                                    description: WStrings.Wallet_RestoreFailed_Text.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    func createWalletPressed() {
        // TODO:: Show loading

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

            }, error: { [weak self] _ in
                guard let self else  { return }
                showAlert()
            })
        }, error: { [weak self] _ in
            guard let self else  { return }
            showAlert()
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
