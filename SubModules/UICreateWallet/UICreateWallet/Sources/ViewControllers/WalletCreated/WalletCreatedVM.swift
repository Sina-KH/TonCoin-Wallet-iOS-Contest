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
    var isLoading: Bool { get set }
    func wordsLoaded(words: [String])
    func errorOccured()
}

class WalletCreatedVM {

    weak var walletCreatedVMDelegate: WalletCreatedVMDelegate?
    init(walletCreatedVMDelegate: WalletCreatedVMDelegate) {
        self.walletCreatedVMDelegate = walletCreatedVMDelegate
    }

    func loadWords(walletContext: WalletContext, walletInfo: WalletInfo) {
        if walletCreatedVMDelegate?.isLoading ?? true {
            return
        }
        walletCreatedVMDelegate?.isLoading = true
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

                    walletCreatedVMDelegate?.isLoading = false
                    walletCreatedVMDelegate?.wordsLoaded(words: wordList)
                }, error: { [weak self] _ in
                    guard let self else {
                        return
                    }
                    
                    walletCreatedVMDelegate?.isLoading = false
                    walletCreatedVMDelegate?.errorOccured()
                })
            }, error: { [weak self] _ in
                guard let self else {
                    return
                }
                
                walletCreatedVMDelegate?.isLoading = false
                walletCreatedVMDelegate?.errorOccured()
            })
        }, error: { [weak self] error in
            guard let self else {
                return
            }
            walletCreatedVMDelegate?.isLoading = false
            if case .cancelled = error {
            } else {
                walletCreatedVMDelegate?.errorOccured()
            }
        })
    }
}
