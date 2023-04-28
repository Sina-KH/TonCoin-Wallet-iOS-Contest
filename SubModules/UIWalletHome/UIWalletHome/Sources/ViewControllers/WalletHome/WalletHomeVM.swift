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

enum WalletInfoTransaction: Equatable {
    case completed(WalletTransaction)
    case pending(PendingWalletTransaction)
}

private enum WalletInfoListEntryId: Hashable {
    case empty
    case transaction(WalletTransactionId)
    case pendingTransaction(Data)
}

private enum WalletInfoListEntry: Equatable, Comparable, Identifiable {
    case empty(String, Bool)
    case transaction(Int, WalletInfoTransaction)
    
    var stableId: WalletInfoListEntryId {
        switch self {
        case .empty:
            return .empty
        case let .transaction(_, transaction):
            switch transaction {
            case let .completed(completed):
                return .transaction(completed.transactionId)
            case let .pending(pending):
                return .pendingTransaction(pending.bodyHash)
            }
        }
    }
    
    static func <(lhs: WalletInfoListEntry, rhs: WalletInfoListEntry) -> Bool {
        switch lhs {
        case .empty:
            switch rhs {
            case .empty:
                return false
            case .transaction:
                return true
            }
        case let .transaction(lhsIndex, _):
            switch rhs {
            case .empty:
                return false
            case let .transaction(rhsIndex, _):
                return lhsIndex < rhsIndex
            }
        }
    }
//
//    func item(theme: WalletTheme, strings: WalletStrings, dateTimeFormat: WalletPresentationDateTimeFormat, action: @escaping (WalletInfoTransaction) -> Void, displayAddressContextMenu: @escaping (ASDisplayNode, CGRect) -> Void) -> ListViewItem {
//        switch self {
//        case let .empty(address, loading):
//            return WalletInfoEmptyItem(theme: theme, strings: strings, address: address, loading: loading, displayAddressContextMenu: { node, frame in
//                displayAddressContextMenu(node, frame)
//            })
//        case let .transaction(_, transaction):
//            return WalletInfoTransactionItem(theme: theme, strings: strings, dateTimeFormat: dateTimeFormat, walletTransaction: transaction, action: {
//                action(transaction)
//            })
//        }
//    }
}

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
        initWalletInfo()
    }

    // MARK: - Wallet Public Variables
    var transactions: [WalletTransaction]? = nil
    var combinedState: CombinedWalletState?
    
    // MARK: - Wallet Logic Variables
    private let stateDisposable = MetaDisposable()
    private let transactionListDisposable = MetaDisposable()
    private let transactionDecryptionKey = Promise<WalletTransactionDecryptionKey?>(nil)
    private var transactionDecryptionKeyDisposable: Disposable?
    
    private var loadingMoreTransactions: Bool = false
    private var canLoadMoreTransactions: Bool = true
    private var currentEntries: [WalletInfoListEntry]?
    private var reloadingState: Bool = false
    private let statePromise = Promise<(CombinedWalletState, Bool)>()
    
    private var pollCombinedStateDisposable: Disposable?
    private var watchCombinedStateDisposable: Disposable?
    private var refreshProgressDisposable: Disposable?

    // MARK: - Init wallet info
    private func initWalletInfo() {
        let subject: CombinedWalletStateSubject = .wallet(walletInfo)

        let watchCombinedStateSignal = walletContext.storage.watchWalletRecords()
        |> map { records -> CombinedWalletState? in
            for record in records {
                switch record.info {
                case let .ready(itemInfo, _, state):
                    if itemInfo.publicKey == self.walletInfo.publicKey {
                        return state
                    }
                case .imported:
                    break
                }
            }
            return nil
        }
        |> distinctUntilChanged
        
        let tonInstance = walletContext.tonInstance
        let decryptedWalletState = combineLatest(queue: .mainQueue(),
            watchCombinedStateSignal,
            self.transactionDecryptionKey.get()
        )
        |> mapToSignal { maybeState, decryptionKey -> Signal<CombinedWalletState?, NoError> in
            guard let state = maybeState, let decryptionKey = decryptionKey else {
                return .single(maybeState)
            }
            return decryptWalletTransactions(decryptionKey: decryptionKey, transactions: state.topTransactions, tonInstance: tonInstance)
            |> `catch` { _ -> Signal<[WalletTransaction], NoError> in
                return .single(state.topTransactions)
            }
            |> map { transactions -> CombinedWalletState? in
                return state.withTopTransactions(transactions)
            }
        }
        
        self.watchCombinedStateDisposable = (decryptedWalletState
        |> deliverOnMainQueue).start(next: { [weak self] state in
            guard let strongSelf = self, let state = state else {
                return
            }
            
            if state.pendingTransactions != strongSelf.combinedState?.pendingTransactions || state.timestamp != strongSelf.combinedState?.timestamp {
                if !strongSelf.reloadingState {
                    self?.combinedState = state
                    strongSelf.walletHomeVMDelegate?.updateCombinedState(combinedState: state, isUpdated: true)
                }
            }
        })
        
        let pollCombinedState: Signal<Never, NoError> = (
            getCombinedWalletState(storage: walletContext.storage, subject: subject, tonInstance: walletContext.tonInstance, onlyCached: false)
            |> ignoreValues
            |> `catch` { _ -> Signal<Never, NoError> in
                return .complete()
            }
            |> then(
                Signal<Never, NoError>.complete()
                |> delay(5.0, queue: .mainQueue())
            )
        )
        |> restart
        
        self.pollCombinedStateDisposable = (pollCombinedState
        |> deliverOnMainQueue).start()
        
        self.refreshProgressDisposable = (walletContext.tonInstance.syncProgress
        |> deliverOnMainQueue).start(next: { [weak self] progress in
            guard let strongSelf = self else {
                return
            }
            // TODO:: strongSelf.headerNode.refreshNode.refreshProgress = progress
//            if strongSelf.headerNode.isRefreshing, strongSelf.isReady, let (_, _) = strongSelf.validLayout {
//                strongSelf.headerNode.refreshNode.update(state: .refreshing)
//            }
        })
        
        self.transactionDecryptionKeyDisposable = (self.transactionDecryptionKey.get()
        |> deliverOnMainQueue).start(next: { [weak self] value in
            guard let strongSelf = self else {
                return
            }
            if let value = value, let currentEntries = strongSelf.currentEntries {
                var encryptedTransactions: [WalletTransactionId: WalletTransaction] = [:]
                for entry in currentEntries {
                    switch entry {
                    case .empty:
                        break
                    case let .transaction(_, transaction):
                        switch transaction {
                        case let .completed(transaction):
                            var isEncrypted = false
                            if let inMessage = transaction.inMessage {
                                switch inMessage.contents {
                                case .encryptedText:
                                    isEncrypted = true
                                default:
                                    break
                                }
                            }
                            for outMessage in transaction.outMessages {
                                switch outMessage.contents {
                                case .encryptedText:
                                    isEncrypted = true
                                default:
                                    break
                                }
                            }
                            if isEncrypted {
                                encryptedTransactions[transaction.transactionId] = transaction
                            }
                        case .pending:
                            break
                        }
                    }
                }
                
                if !encryptedTransactions.isEmpty {
                    let _ = (decryptWalletTransactions(decryptionKey: value, transactions: Array(encryptedTransactions.values), tonInstance: strongSelf.walletContext.tonInstance)
                    |> deliverOnMainQueue).start(next: { decryptedTransactions in
                        guard let strongSelf = self else {
                            return
                        }
                        var decryptedTransactionMap: [WalletTransactionId: WalletTransaction] = [:]
                        for transaction in decryptedTransactions {
                            decryptedTransactionMap[transaction.transactionId] = transaction
                        }
                        var updatedEntries: [WalletInfoListEntry] = []
                        for entry in currentEntries {
                            switch entry {
                            case .empty:
                                updatedEntries.append(entry)
                            case let .transaction(index, transaction):
                                switch transaction {
                                case .pending:
                                    updatedEntries.append(entry)
                                case let .completed(transaction):
                                    if let decryptedTransaction = decryptedTransactionMap[transaction.transactionId] {
                                        updatedEntries.append(.transaction(index, .completed(decryptedTransaction)))
                                    } else {
                                        updatedEntries.append(entry)
                                    }
                                }
                            }
                        }
                        strongSelf.replaceEntries(updatedEntries)
                    })
                }
            }
        })
    }
    
    // MARK: - replaceEntries
    private func replaceEntries(_ updatedEntries: [WalletInfoListEntry]) {
//        let transaction = preparedTransition(from: self.currentEntries ?? [], to: updatedEntries, presentationData: self.presentationData, action: { [weak self] transaction in
//            guard let strongSelf = self else {
//                return
//            }
//            strongSelf.openTransaction(transaction)
//        }, displayAddressContextMenu: { [weak self] node, frame in
//            guard let strongSelf = self else {
//                return
//            }
//            let address = strongSelf.walletInfo.address
//            let contextMenuController = ContextMenuController(actions: [ContextMenuAction(content: .text(title: strongSelf.presentationData.strings.Wallet_ContextMenuCopy, accessibilityLabel: strongSelf.presentationData.strings.Wallet_ContextMenuCopy), action: {
//                UIPasteboard.general.string = address
//            })])
//            strongSelf.present(contextMenuController, ContextMenuControllerPresentationArguments(sourceNodeAndRect: { [weak self] in
//                if let strongSelf = self {
//                    return (node, frame.insetBy(dx: 0.0, dy: -2.0), strongSelf, strongSelf.view.bounds)
//                } else {
//                    return nil
//                }
//            }))
//        })
//        self.currentEntries = updatedEntries
//
//        self.enqueuedTransactions.append(transaction)
//        self.dequeueTransaction()
    }
    
    private func dequeueTransaction() {
//        self.enqueuedTransactions.remove(at: 0)
//
//        self.listNode.transaction(deleteIndices: transaction.deletions, insertIndicesAndItems: transaction.insertions, updateIndicesAndItems: transaction.updates, options: options, updateSizeAndInsets: nil, updateOpaqueState: nil, completion: { _ in
//        })
    }
    
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
            strongSelf.transactions = combinedState?.topTransactions
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
