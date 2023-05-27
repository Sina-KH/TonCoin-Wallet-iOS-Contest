//
//  ImportSuccessVM.swift
//  UICreateWallet
//
//  Created by Sina on 4/21/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol ImportSuccessVMDelegate: AnyObject {
    var isLoading: Bool { get set }
    func importCompleted(walletInfo: WalletInfo)
    func errorOccured()
}

class ImportSuccessVM {
    
    weak var importSuccessVMDelegate: ImportSuccessVMDelegate? = nil
    init(importSuccessVMDelegate: ImportSuccessVMDelegate) {
        self.importSuccessVMDelegate = importSuccessVMDelegate
    }
    
    // TODO:: Handle adnl timeout errors! Sometimes lite client receives errors on unstable networks, that may be not handled!
    public func loadWalletInfo(walletContext: WalletContext, importedInfo: ImportedWalletInfo) {
        if importSuccessVMDelegate?.isLoading ?? true {
            return
        }
        importSuccessVMDelegate?.isLoading = true
        let signal = getWalletInfo(importedInfo: importedInfo, tonInstance: walletContext.tonInstance)
        |> mapError { error -> GetCombinedWalletStateError in
            switch error {
            case .generic:
                return .generic
            }
        }
        |> mapToSignal { walletInfo -> Signal<WalletCreatedPreloadState?, GetCombinedWalletStateError> in
            return walletContext.storage.updateWalletRecords { records in
                var records = records
                for i in 0 ..< records.count {
                    switch records[i].info {
                    case .ready:
                        break
                    case let .imported(info):
                        if info.publicKey == importedInfo.publicKey {
                            records[i].info = .ready(info: walletInfo, exportCompleted: .no(isImport: true), state: nil)
                        }
                    }
                }
                return records
            }
            |> castError(GetCombinedWalletStateError.self)
            |> mapToSignal { _ -> Signal<WalletCreatedPreloadState?, GetCombinedWalletStateError> in
                return getCombinedWalletState(storage: walletContext.storage, subject: .wallet(walletInfo), tonInstance: walletContext.tonInstance, onlyCached: false)
                |> map { state -> WalletCreatedPreloadState? in
                    return WalletCreatedPreloadState(info: walletInfo, state: state)
                }
            }
        }
        |> `catch` { _ -> Signal<WalletCreatedPreloadState?, NoError> in
            return .single(nil)
        }
        |> filter { $0 != nil }
        |> take(1)
        |> deliverOnMainQueue
        _ = signal.start(next: { [weak self] state in
            self?.importSuccessVMDelegate?.isLoading = false
            guard let state else {
                self?.importSuccessVMDelegate?.errorOccured()
                return
            }
            // wallet import completed
            self?.importSuccessVMDelegate?.importCompleted(walletInfo: state.info)
        }, error: { [weak self] error in
            self?.importSuccessVMDelegate?.errorOccured()
        })
    }
}
