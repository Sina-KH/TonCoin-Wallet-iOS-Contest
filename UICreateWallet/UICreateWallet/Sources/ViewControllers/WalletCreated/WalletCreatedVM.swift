//
//  WalletCreatedVM.swift
//  UICreateWallet
//
//  Created by Sina on 4/14/23.
//

import Foundation
import SwiftSignalKit
import WalletCore
import WalletContext

protocol WalletCreatedVMDelegate: AnyObject {
    func wordsLoaded(words: [String])
    func errorOccured()
}

class WalletCreatedVM {

    weak var walletCreatedVMDelegate: WalletCreatedVMDelegate?
    init(walletCreatedVMDelegate: WalletCreatedVMDelegate) {
        self.walletCreatedVMDelegate = walletCreatedVMDelegate
    }

    func loadWords(walletContext: WalletContext, walletInfo: WalletInfo) {
        let _ = (walletContext.keychain.decrypt(walletInfo.encryptedSecret)
        |> deliverOnMainQueue).start(next: { [weak self] decryptedSecret in
            let _ = (walletContext.getServerSalt()
            |> deliverOnMainQueue).start(next: { [weak self] serverSalt in
                let _ = (walletRestoreWords(tonInstance: walletContext.tonInstance,
                                            publicKey: walletInfo.publicKey,
                                            decryptedSecret:  decryptedSecret,
                                            localPassword: serverSalt)
                |> deliverOnMainQueue).start(next: { [weak self] wordList in
                    guard let self else {
                        return
                    }

                    walletCreatedVMDelegate?.wordsLoaded(words: wordList)
//                    strongSelf.mode = .created(walletInfo: walletInfo, words: wordList)
//                    strongSelf.push(WalletWordDisplayScreen(context: strongSelf.context, blockchainNetwork: strongSelf.blockchainNetwork, walletInfo: walletInfo, wordList: wordList, mode: .check, walletCreatedPreloadState: strongSelf.walletCreatedPreloadState))
                }, error: { [weak self] _ in
                    guard let self else {
                        return
                    }
                    
                    walletCreatedVMDelegate?.errorOccured()
//                    strongSelf.present(standardTextAlertController(theme: strongSelf.presentationData.theme.alert, title: strongSelf.presentationData.strings.Wallet_Created_ExportErrorTitle, text: strongSelf.presentationData.strings.Wallet_Created_ExportErrorText, actions: [
//                        TextAlertAction(type: .defaultAction, title: strongSelf.presentationData.strings.Wallet_Alert_OK, action: {
//                        })
//                    ], actionLayout: .vertical), in: .window(.root))
                })
            }, error: { [weak self] _ in
                guard let self else {
                    return
                }
                
                walletCreatedVMDelegate?.errorOccured()
//                controller?.dismiss()
//
//                strongSelf.present(standardTextAlertController(theme: strongSelf.presentationData.theme.alert, title: strongSelf.presentationData.strings.Wallet_Created_ExportErrorTitle, text: strongSelf.presentationData.strings.Wallet_Created_ExportErrorText, actions: [
//                    TextAlertAction(type: .defaultAction, title: strongSelf.presentationData.strings.Wallet_Alert_OK, action: {
//                    })
//                ], actionLayout: .vertical), in: .window(.root))
            })
        }, error: { [weak self] error in
            guard let self else {
                return
            }
//            controller?.dismiss()
            if case .cancelled = error {
            } else {
                walletCreatedVMDelegate?.errorOccured()
//                strongSelf.present(standardTextAlertController(theme: strongSelf.presentationData.theme.alert, title: strongSelf.presentationData.strings.Wallet_Created_ExportErrorTitle, text: strongSelf.presentationData.strings.Wallet_Created_ExportErrorText, actions: [
//                    TextAlertAction(type: .defaultAction, title: strongSelf.presentationData.strings.Wallet_Alert_OK, action: {
//                    })
//                ], actionLayout: .vertical), in: .window(.root))
            }
        })
    }
}
