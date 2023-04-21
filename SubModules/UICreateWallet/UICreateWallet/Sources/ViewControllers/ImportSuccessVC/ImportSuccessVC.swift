//
//  ImportSuccessVC.swift
//  UICreateWallet
//
//  Created by Sina on 4/21/23.
//

import UIKit
import WalletCore
import WalletContext
import UIPasscode
import UIWalletHome
import UIComponents

public class ImportSuccessVC: WViewController {
    
    var walletContext: WalletContext
    var importedWalletInfo: ImportedWalletInfo
    public init(walletContext: WalletContext,
                importedWalletInfo: ImportedWalletInfo) {
        self.walletContext = walletContext
        self.importedWalletInfo = importedWalletInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    lazy var importSuccessVM = ImportSuccessVM(importSuccessVMDelegate: self)
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func loadView() {
        super.loadView()
        setupViews()
    }

    func setupViews() {
        navigationItem.hidesBackButton = true

        let proceedAction = BottomAction(
            title: WStrings.Wallet_Created_Proceed.localized,
            onPress: {
                self.proceedPressed()
            }
        )
        
        let bottomActionsView = BottomActionsView(primaryAction: proceedAction)
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

        let headerView = HeaderView(animationName: "Congratulations",
                                    animationPlaybackMode: .once,
                                    title: WStrings.Wallet_ImportSuccessful_Title.localized)
        topView.addSubview(headerView)
        NSLayoutConstraint.activate([
            headerView.leftAnchor.constraint(equalTo: topView.leftAnchor, constant: 32),
            headerView.rightAnchor.constraint(equalTo: topView.rightAnchor, constant: -32),
            headerView.centerYAnchor.constraint(equalTo: topView.centerYAnchor)
        ])
    }

    func proceedPressed() {
        importSuccessVM.loadWalletInfo(walletContext: walletContext, importedInfo: importedWalletInfo)
    }
    
}

extension ImportSuccessVC: ImportSuccessVMDelegate {
    func importCompleted(walletInfo: WalletInfo) {
        // all the words are correct
        let nextVC = BiometricHelper.biometricType() == .none ?
        CompletedVC(walletContext: walletContext, walletInfo: walletInfo) :
        SetPasscodeVC(walletContext: walletContext, walletInfo: walletInfo, onCompletion: { [weak self] in
            guard let self else {return}
            // set passcode flow completion
            // update wallet core state
            _ = confirmWalletExported(storage: walletContext.storage, publicKey: walletInfo.publicKey).start()
            // navigate to completed vc
            navigationController?.pushViewController(CompletedVC(walletContext: walletContext, walletInfo: walletInfo), animated: true)
        })
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    public func errorOccured(text: String) {
        // TODO::
    }
}
