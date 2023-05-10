//
//  ImportWalletVM.swift
//  UICreateWallet
//
//  Created by Sina on 4/21/23.
//

import Foundation
import SwiftSignalKit
import WalletCore
import WalletContext

public protocol ImportWalletVMDelegate: AnyObject {
    var isLoading: Bool { get set }
    func walletImported(walletInfo: ImportedWalletInfo)
    func errorOccured()
}

public struct WalletCreatedPreloadState {
    let info: WalletInfo
    let state: CombinedWalletStateResult
}

public class ImportWalletVM {
    
    weak var importWalletVMDelegate: ImportWalletVMDelegate?
    public init(importWalletVMDelegate: ImportWalletVMDelegate) {
        self.importWalletVMDelegate = importWalletVMDelegate
    }
    
    func importWallet(walletContext: WalletContext, enteredWords: [String]) {
        if importWalletVMDelegate?.isLoading ?? true {
            return
        }
        importWalletVMDelegate?.isLoading = true
        let _ = (walletContext.getServerSalt()
                 |> deliverOnMainQueue).start(next: { [weak self] serverSalt in
            guard let self else {return}
            let _ = (WalletCore.importWallet(storage: walletContext.storage,
                                             tonInstance: walletContext.tonInstance,
                                             keychain: walletContext.keychain,
                                             wordList: enteredWords,
                                             localPassword: serverSalt)
                     |> deliverOnMainQueue).start(next: { [weak self] importedInfo in
                self?.importWalletVMDelegate?.isLoading = false
                self?.importWalletVMDelegate?.walletImported(walletInfo: importedInfo)
            }, error: { [weak self] error in
                self?.importWalletVMDelegate?.isLoading = false
                self?.importWalletVMDelegate?.errorOccured()
            })
        }, error: { [weak self] error in
            self?.importWalletVMDelegate?.isLoading = false
            self?.importWalletVMDelegate?.errorOccured()
        })
        
    }
}

