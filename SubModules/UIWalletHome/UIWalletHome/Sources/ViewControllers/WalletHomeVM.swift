//
//  WalletHomeVM.swift
//  UIWalletHome
//
//  Created by Sina on 4/20/23.
//

import Foundation
import WalletContext
import WalletCore
import SwiftSignalKit

protocol WalletHomeVMDelegate: AnyObject {
    func updateCombinedState(combinedState: CombinedWalletState?, isUpdated: Bool)
    func refreshErrorOccured(error: GetCombinedWalletStateError)
}

class WalletHomeVM {
    
    // MARK: - Initializer
    private var walletContext: WalletContext
    private var walletInfo: WalletInfo
    private weak var walletHomeVMDelegate: WalletHomeVMDelegate?
    init(walletContext: WalletContext, walletInfo: WalletInfo, walletHomeVMDelegate: WalletHomeVMDelegate) {
        self.walletContext = walletContext
        self.walletInfo = walletInfo
        self.walletHomeVMDelegate = walletHomeVMDelegate
    }

    // MARK: - Wallet Logic Variables
    private let stateDisposable = MetaDisposable()
    private let transactionListDisposable = MetaDisposable()
    private let transactionDecryptionKey = Promise<WalletTransactionDecryptionKey?>(nil)
    private var transactionDecryptionKeyDisposable: Disposable?
    
    private var loadingMoreTransactions: Bool = false
    private var canLoadMoreTransactions: Bool = true
    private var reloadingState: Bool = false
    private var combinedState: CombinedWalletState?
    private let statePromise = Promise<(CombinedWalletState, Bool)>()
    
    // MARK: - Refresh the transactions
    func refreshTransactions() {
        self.transactionListDisposable.set(nil)
        self.loadingMoreTransactions = true
        self.reloadingState = true
        self.updateStatePromise()

        // TODO::
        //self.headerNode.isRefreshing = true
        //self.headerNode.refreshNode.refreshProgress = 0.0
        
        let subject: CombinedWalletStateSubject = .wallet(self.walletInfo)
        
        let transactionDecryptionKey = self.transactionDecryptionKey
        let tonInstance = walletContext.tonInstance
        let processedWalletState = getCombinedWalletState(storage: walletContext.storage, subject: subject,
                                                          tonInstance: tonInstance,
                                                          onlyCached: false)
        |> mapToSignal { state -> Signal<CombinedWalletStateResult, GetCombinedWalletStateError> in
            return transactionDecryptionKey.get()
            |> castError(GetCombinedWalletStateError.self)
            |> take(1)
            |> mapToSignal { decryptionKey -> Signal<CombinedWalletStateResult, GetCombinedWalletStateError> in
                guard let decryptionKey = decryptionKey else {
                    return .single(state)
                }
                switch state {
                case let .cached(value):
                    if let value = value {
                        return decryptWalletState(decryptionKey: decryptionKey, state: value, tonInstance: tonInstance)
                        |> map { decryptedState -> CombinedWalletStateResult in
                            return .cached(decryptedState)
                        }
                        |> `catch` { _ -> Signal<CombinedWalletStateResult, GetCombinedWalletStateError> in
                            return .single(state)
                        }
                    } else {
                        return .single(state)
                    }
                case let .updated(value):
                    return decryptWalletState(decryptionKey: decryptionKey, state: value, tonInstance: tonInstance)
                    |> map { decryptedState -> CombinedWalletStateResult in
                        return .updated(decryptedState)
                    }
                    |> `catch` { _ -> Signal<CombinedWalletStateResult, GetCombinedWalletStateError> in
                        return .single(state)
                    }
                }
            }
        }
        
        self.stateDisposable.set((processedWalletState
        |> deliverOnMainQueue).start(next: { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            let combinedState: CombinedWalletState?
            var isUpdated = false
            switch value {
            case let .cached(state):
                if strongSelf.combinedState != nil {
                    return
                }
                combinedState = state
            case let .updated(state):
                isUpdated = true
                combinedState = state
            }
            
            strongSelf.combinedState = combinedState
            strongSelf.reloadingState = !isUpdated
            
            // notify WalletHomeVC from latest combined state
            strongSelf.walletHomeVMDelegate?.updateCombinedState(combinedState: combinedState, isUpdated: isUpdated)

            strongSelf.updateStatePromise()
        }, error: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.reloadingState = false
            strongSelf.updateStatePromise()
            
            if let combinedState = strongSelf.combinedState {
                // TODO:: strongSelf.headerNode.timestamp = Int32(clamping: combinedState.timestamp)
            }
                
            // TODO::
//            if strongSelf.isReady, let (_, navigationHeight) = strongSelf.validLayout {
//                strongSelf.headerNode.update(size: strongSelf.headerNode.bounds.size, navigationHeight: navigationHeight, offset: strongSelf.listOffset ?? 0.0, transition: .immediate, isScrolling: false)
//            }
                
            strongSelf.loadingMoreTransactions = false
            strongSelf.canLoadMoreTransactions = false
                
            // TODO:: strongSelf.headerNode.isRefreshing = false
            
            // TODO::
//            if strongSelf.isReady, let (_, navigationHeight) = strongSelf.validLayout {
//                strongSelf.headerNode.update(size: strongSelf.headerNode.bounds.size, navigationHeight: navigationHeight, offset: strongSelf.listOffset ?? 0.0, transition: .animated(duration: 0.2, curve: .easeInOut), isScrolling: false)
//            }
            
            // TODO::
//            if !strongSelf.didSetContentReady {
//                strongSelf.didSetContentReady = true
//                strongSelf.contentReady.set(.single(true))
//            }

            // refresh error occured
            strongSelf.walletHomeVMDelegate?.refreshErrorOccured(error: error)
        }))
    }
    
    private func updateStatePromise() {
        if let combinedState = self.combinedState {
            self.statePromise.set(.single((combinedState, self.reloadingState)))
        }
    }
}
