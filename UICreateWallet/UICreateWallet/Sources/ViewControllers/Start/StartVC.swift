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

public class StartVC: UIViewController {

    var walletContext: WalletContext

    public init(walletContext: WalletContext,
                nibName nibNameOrNil: String?,
                bundle nibBundleOrNil: Bundle?) {
        self.walletContext = walletContext
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    @IBAction func createWalletPressed(_ sender: Any) {
//        let controller = OverlayStatusController(theme: strongSelf.presentationData.theme, type: .loading(cancelled: nil))
//        let displayError: () -> Void = {
//            guard let strongSelf = self else {
//                return
//            }
//            controller.dismiss()
//            strongSelf.present(standardTextAlertController(theme: strongSelf.presentationData.theme.alert, title: strongSelf.presentationData.strings.Wallet_Intro_CreateErrorTitle, text: strongSelf.presentationData.strings.Wallet_Intro_CreateErrorText, actions: [
//                TextAlertAction(type: .defaultAction, title: strongSelf.presentationData.strings.Wallet_Alert_OK, action: {
//                })
//            ], actionLayout: .vertical), in: .window(.root))
//        }
//        strongSelf.present(controller, in: .window(.root))
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
                                                      wordList: wordList,
                                                      nibName: "WalletCreatedVC",
                                                      bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet"))
                navigationController?.pushViewController(walletCreatedVC, animated: true)

            }, error: { [weak self] _ in
                guard let self else  { return }
                showError()
            })
        }, error: { [weak self] _ in
            guard let self else  { return }
            showError()
        })
    }
    
    @IBAction func importWalletPressed(_ sender: Any) {
    }
    
    func showError() {
        // TODO:: Check strings
        showError(title: walletContext.presentationData.strings.Wallet_Intro_CreateErrorTitle,
                  text: walletContext.presentationData.strings.Wallet_Intro_CreateErrorText,
                  button: walletContext.presentationData.strings.Wallet_Alert_OK)
    }
}
