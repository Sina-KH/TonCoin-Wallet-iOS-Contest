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
    func updateBalance(balance: Int64)
    func updateHeaderTimestamp(timestamp: Int32)
    func updateEmptyView()
    func reloadTableView(deleteIndices: [HomeDeleteItem],
                         insertIndicesAndItems: [HomeInsertItem],
                         updateIndicesAndItems: [HomeUpdateItem])
    func updateUpdateProgress(to progress: Int)
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
    var combinedState: CombinedWalletState?
    var isRefreshing: Bool = false
    var transactions: [HomeListTransaction]? = nil
    
    // MARK: - Wallet Logic Variables
    private let stateDisposable = MetaDisposable()
    private let transactionListDisposable = MetaDisposable()
    private let transactionDecryptionKey = Promise<WalletTransactionDecryptionKey?>(nil)
    private var transactionDecryptionKeyDisposable: Disposable?
    
    private var loadingMoreTransactions: Bool = false
    private var canLoadMoreTransactions: Bool = true
    private var currentEntries: [HomeListItemEntry]?
    private var reloadingState: Bool = false
    private let statePromise = Promise<(CombinedWalletState, Bool)>()
    
    // list of updates that should be done on transactions list in home page
    private var enqueuedTransactions: [HomeListUpdate] = []
    
    private var pollCombinedStateDisposable: Disposable?
    private var watchCombinedStateDisposable: Disposable?
    private var refreshProgressDisposable: Disposable?
    
    private var prevProgress: Int? = nil
    
    deinit {
        self.stateDisposable.dispose()
        self.transactionListDisposable.dispose()
        //self.updateTimestampTimer?.invalidate()
        self.pollCombinedStateDisposable?.dispose()
        self.watchCombinedStateDisposable?.dispose()
        self.refreshProgressDisposable?.dispose()
        self.transactionDecryptionKeyDisposable?.dispose()
    }
    
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

            // check if delegate exists yet, otherwise, dispose to prevent memory leak
            guard strongSelf.walletHomeVMDelegate != nil else {
                self?.watchCombinedStateDisposable?.dispose()
                return
            }
            
            if state.pendingTransactions != strongSelf.combinedState?.pendingTransactions || state.timestamp != strongSelf.combinedState?.timestamp {
                if !strongSelf.reloadingState {
                    self?.combinedState = state
                    strongSelf.updateCombinedState(combinedState: state, isUpdated: true)
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
        
        // listen for update progress change
        self.refreshProgressDisposable = (walletContext.tonInstance.syncProgress
                                          |> deliverOnMainQueue).start(next: { [weak self] progress in
            if (self?.prevProgress ?? -1) != Int(progress * 100) {
                self?.prevProgress = Int(progress * 100)
                DispatchQueue.main.async {
                    self?.walletHomeVMDelegate?.updateUpdateProgress(to: Int(progress * 100))
                }
            }
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
                    //case .empty:
                    //    break
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
                        var updatedEntries: [HomeListItemEntry] = []
                        for entry in currentEntries {
                            switch entry {
                            //case .empty:
                            //    updatedEntries.append(entry)
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
    
    // MARK: - Refresh the transactions
    func refreshTransactions() {
        self.transactionListDisposable.set(nil)
        self.loadingMoreTransactions = true
        self.reloadingState = true
        self.updateStatePromise()
        
        // TODO:: pull to refresh required (?)
        isRefreshing = true
        
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
            strongSelf.updateCombinedState(combinedState: combinedState, isUpdated: isUpdated)
            
            strongSelf.updateStatePromise()
        }, error: { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.reloadingState = false
            strongSelf.updateStatePromise()
            
            //if let combinedState = strongSelf.combinedState {
            // strongSelf.headerNode.timestamp = Int32(clamping: combinedState.timestamp)
            //}
            
            strongSelf.loadingMoreTransactions = false
            strongSelf.canLoadMoreTransactions = false
            
            strongSelf.isRefreshing = false
            
            // refresh error occured
            strongSelf.walletHomeVMDelegate?.refreshErrorOccured(error: error)
        }))
    }
    
    private func updateStatePromise() {
        if let combinedState = self.combinedState {
            self.statePromise.set(.single((combinedState, self.reloadingState)))
        }
    }
    
    // MARK: - Load more transactions
    func loadMoreTransactions() {
        if loadingMoreTransactions || reloadingState || !canLoadMoreTransactions {
            return
        }
        self.loadingMoreTransactions = true
        var lastTransactionId: WalletTransactionId?
        if let last = self.currentEntries?.last {
            switch last {
            case let .transaction(_, transaction):
                switch transaction {
                case let .completed(completed):
                    lastTransactionId = completed.transactionId
                case .pending:
                    break
                }
            //case .empty:
            //    break
            }
        }
        let transactionDecryptionKey = self.transactionDecryptionKey
        let tonInstance = walletContext.tonInstance
        let requestTransactions = getWalletTransactions(address: self.walletInfo.address, previousId: lastTransactionId, tonInstance: tonInstance)
        let processedTransactions = requestTransactions
        |> mapToSignal { transactions -> Signal<[WalletTransaction], GetWalletTransactionsError> in
            return transactionDecryptionKey.get()
            |> castError(GetWalletTransactionsError.self)
            |> take(1)
            |> mapToSignal { decryptionKey -> Signal<[WalletTransaction], GetWalletTransactionsError> in
                guard let decryptionKey = decryptionKey else {
                    return .single(transactions)
                }
                return decryptWalletTransactions(decryptionKey: decryptionKey, transactions: transactions, tonInstance: tonInstance)
                |> `catch` { _ -> Signal<[WalletTransaction], GetWalletTransactionsError> in
                    return .single(transactions)
                }
            }
        }
        self.transactionListDisposable.set((processedTransactions
        |> deliverOnMainQueue).start(next: { [weak self] transactions in
            guard let strongSelf = self else {
                return
            }
            strongSelf.transactionsLoaded(isReload: false, isEmpty: false, transactions: transactions, pendingTransactions: [])
        }, error: { _ in
        }))
    }
    
    // MARK: - Update Combined State
    // called on each state update to update needed views
    func updateCombinedState(combinedState: CombinedWalletState?, isUpdated: Bool) {
        if let combinedState = combinedState {
            // TODO:: Show locked balance in a separate label?

            EventsHelper.balanceUpdated(to: combinedState.walletState.effectiveAvailableBalance)
            walletHomeVMDelegate?.updateBalance(balance: combinedState.walletState.effectiveAvailableBalance)
            
            walletHomeVMDelegate?.updateHeaderTimestamp(timestamp: Int32(clamping: combinedState.timestamp))
            
            var updatedTransactions: [WalletTransaction] = combinedState.topTransactions
            if updatedTransactions.count > 0 {
            }
            if let currentEntries = self.currentEntries {
                var existingIds = Set<HomeListItemID>()
                for transaction in updatedTransactions {
                    existingIds.insert(.transaction(transaction.transactionId))
                }
                for entry in currentEntries {
                    switch entry {
                    case let .transaction(_, transaction):
                        switch transaction {
                        case let .completed(transaction):
                            if !existingIds.contains(.transaction(transaction.transactionId)) {
                                existingIds.insert(.transaction(transaction.transactionId))
                                updatedTransactions.append(transaction)
                            }
                        case .pending:
                            break
                        }
                    default:
                        break
                    }
                }
            }
            
            self.transactionsLoaded(isReload: true, isEmpty: false, transactions: updatedTransactions, pendingTransactions: combinedState.pendingTransactions)
            
            //            if isUpdated {
            //                self.headerNode.isRefreshing = false
            //            }
            
            //            if self.isReady, let (_, navigationHeight) = self.validLayout {
            //                self.headerNode.update(size: self.headerNode.bounds.size, navigationHeight: navigationHeight, offset: self.listOffset ?? 0.0, transition: .animated(duration: 0.2, curve: .easeInOut), isScrolling: false)
            //            }
        } else {
            //            self.transactionsLoaded(isReload: true, isEmpty: true, transactions: [], pendingTransactions: [])
        }
        //
        //        let wasReady = self.isReady
        //        self.isReady = true
        //
        //        if self.isReady && !wasReady {
        //            if let (layout, navigationHeight) = self.validLayout {
        //                self.headerNode.update(size: self.headerNode.bounds.size, navigationHeight: navigationHeight, offset: layout.size.height, transition: .immediate, isScrolling: false)
        //            }
        //
        //            self.becameReady(animated: self.didSetContentReady)
        //        }
        
        //        if !self.didSetContentReady {
        //            self.didSetContentReady = true
        //            self.contentReady.set(.single(true))
        //        }

        walletHomeVMDelegate?.updateEmptyView()
    }
    
    private func transactionsLoaded(isReload: Bool,
                                    isEmpty: Bool,
                                    transactions: [WalletTransaction],
                                    pendingTransactions: [PendingWalletTransaction]) {
        if !isEmpty {
            self.loadingMoreTransactions = false
            self.canLoadMoreTransactions = transactions.count > 2
        }
        
        var updatedEntries: [HomeListItemEntry] = []
        if isReload {
            var existingIds = Set<HomeListItemID>()
            for transaction in pendingTransactions {
                if !existingIds.contains(.pendingTransaction(transaction.bodyHash)) {
                    existingIds.insert(.pendingTransaction(transaction.bodyHash))
                    updatedEntries.append(.transaction(updatedEntries.count, .pending(transaction)))
                }
            }
            for transaction in transactions {
                if !existingIds.contains(.transaction(transaction.transactionId)) {
                    existingIds.insert(.transaction(transaction.transactionId))
                    updatedEntries.append(.transaction(updatedEntries.count, .completed(transaction)))
                }
            }
            //if updatedEntries.isEmpty {
            //    updatedEntries.append(.empty(self.walletInfo.address, isEmpty))
            //}
        } else {
            updatedEntries = self.currentEntries ?? []
            updatedEntries = updatedEntries.filter { entry in
                //if case .empty = entry {
                //    return false
                //} else {
                    return true
                //}
            }
            var existingIds = Set<HomeListItemID>()
            for entry in updatedEntries {
                switch entry {
                case .transaction:
                    existingIds.insert(entry.stableId)
                //case .empty:
                //    break
                }
            }
            for transaction in transactions {
                if !existingIds.contains(.transaction(transaction.transactionId)) {
                    existingIds.insert(.transaction(transaction.transactionId))
                    updatedEntries.append(.transaction(updatedEntries.count, .completed(transaction)))
                }
            }
            if updatedEntries.isEmpty {
                //updatedEntries.append(.empty(self.walletInfo.address, false))
            }
        }
        
        self.replaceEntries(updatedEntries)
    }

    // MARK: - replaceEntries, update the list
    private func replaceEntries(_ updatedEntries: [HomeListItemEntry]) {
        let transaction = preparedTransition(from: self.currentEntries ?? [],
                                             to: updatedEntries)
        self.currentEntries = updatedEntries

        transactions = []
        for entry in currentEntries ?? [] {
            switch entry {
            //case .empty(_, _):
            //    break
            case .transaction(_, let trn):
                transactions?.append(trn)
                break
            }
        }

        self.enqueuedTransactions.append(transaction)
        self.dequeueTransaction()
    }
    
    private func preparedTransition(from fromEntries: [HomeListItemEntry],
                                    to toEntries: [HomeListItemEntry]) -> HomeListUpdate {
        let (deleteIndices, indicesAndItems, updateIndices) = mergeListsStableWithUpdates(leftList: fromEntries,
                                                                                          rightList: toEntries)
        
        let deletions = deleteIndices.map { HomeDeleteItem(index: $0, directionHint: nil) }
        let insertions = indicesAndItems.map { HomeInsertItem(index: $0.0, previousIndex: $0.2, directionHint: nil) }
        let updates = updateIndices.map { HomeUpdateItem(index: $0.0, previousIndex: $0.2, directionHint: nil) }
        
        return HomeListUpdate(deletions: deletions, insertions: insertions, updates: updates)
    }
    
    private func dequeueTransaction() {
        guard let transaction = self.enqueuedTransactions.first else {
            return
        }
        self.enqueuedTransactions.remove(at: 0)

        walletHomeVMDelegate?.reloadTableView(deleteIndices: transaction.deletions,
                                              insertIndicesAndItems: transaction.insertions,
                                              updateIndicesAndItems: transaction.updates)
    }
    
}
