//
//  StartVC.swift
//  UICreateWallet
//
//  Created by Sina on 3/31/23.
//

import UIKit
import SwiftSignalKit
import WalletCore
import UIComponents
import WalletContext

public class IntroVC: WViewController {

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
    
    private var bottomActionsView: BottomActionsView!

    func setupViews() {
        // bottom create wallet action
        let createWalletButton = BottomAction(
            title: WStrings.Wallet_Intro_CreateWallet.localized,
            onPress: {
                self.createWalletPressed()
            }
        )
        
        // bottom import wallet action
        let importExistingWalletButton = BottomAction(
            title: WStrings.Wallet_Intro_ImportExisting.localized,
            onPress: {
                self.importWalletPressed()
            }
        )
        
        // bottom actions view
        bottomActionsView = BottomActionsView(primaryAction: createWalletButton,
                                                  secondaryAction: importExistingWalletButton)
        view.addSubview(bottomActionsView)
        NSLayoutConstraint.activate([
            bottomActionsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -58),
            bottomActionsView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 48),
            bottomActionsView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -48),
        ])

        // top view
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            topView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            topView.bottomAnchor.constraint(equalTo: bottomActionsView.topAnchor)
        ])

        // header, center of top view
        let headerView = HeaderView(animationName: "Start",
                                    animationPlaybackMode: .loop,
                                    title: WStrings.Wallet_Intro_Title.localized,
                                    description: WStrings.Wallet_Intro_Text.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    var isLoading = false {
        didSet {
            bottomActionsView.primaryButton.showLoading = isLoading
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
