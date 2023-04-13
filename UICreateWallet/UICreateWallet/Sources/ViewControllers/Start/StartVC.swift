//
//  StartVC.swift
//  UICreateWallet
//
//  Created by Sina on 3/31/23.
//

import UIKit
import SwiftSignalKit
import WalletCore

public class StartVC: UIViewController {

    var walletContext: WalletContext

    public init(walletContext: WalletContext, nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
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
            |> deliverOnMainQueue).start(next: { walletInfo, wordList in
                print(walletInfo)
                print(wordList)
//                controller.dismiss()
//                (strongSelf.navigationController as? NavigationController)?.replaceController(strongSelf, with: WalletSplashScreen(context: strongSelf.context, blockchainNetwork: strongSelf.blockchainNetwork, mode: .created(walletInfo: walletInfo, words: wordList), walletCreatedPreloadState: nil), animated: true)
            }, error: { _ in
//                displayError()
            })
        }, error: { _ in
//            displayError()
        })

        let walletCreatedVC = WalletCreatedVC(nibName: "WalletCreatedVC",
                                              bundle: Bundle(identifier: "org.ton.wallet.UICreateWallet"))
        navigationController?.pushViewController(walletCreatedVC, animated: true)
    }
    
    @IBAction func importWalletPressed(_ sender: Any) {
    }
}
