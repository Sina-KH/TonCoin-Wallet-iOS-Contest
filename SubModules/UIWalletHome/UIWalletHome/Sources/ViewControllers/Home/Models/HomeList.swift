//
//  HomeTransaction.swift
//  UIWalletHome
//
//  Created by Sina on 5/12/23.
//

import Foundation
import WalletCore

enum HomeListTransaction: Equatable {
    case completed(WalletTransaction)
    case pending(PendingWalletTransaction)
}

enum HomeListItemID: Hashable {
    case empty
    case transaction(WalletTransactionId)
    case pendingTransaction(Data)
}

enum HomeListItemEntry: Equatable, Comparable, Identifiable {
    //case empty(String, Bool)
    case transaction(Int, HomeListTransaction)
    
    var stableId: HomeListItemID {
        switch self {
        //case .empty:
        //    return .empty
        case let .transaction(_, transaction):
            switch transaction {
            case let .completed(completed):
                return .transaction(completed.transactionId)
            case let .pending(pending):
                return .pendingTransaction(pending.bodyHash)
            }
        }
    }
    
    static func <(lhs: HomeListItemEntry, rhs: HomeListItemEntry) -> Bool {
        switch lhs {
        /*case .empty:
            switch rhs {
            case .empty:
                return false
            case .transaction:
                return true
            }*/
        case let .transaction(lhsIndex, _):
            switch rhs {
            //case .empty:
            //    return false
            case let .transaction(rhsIndex, _):
                return lhsIndex < rhsIndex
            }
        }
    }
}

struct HomeListUpdate {
    let deletions: [HomeDeleteItem]
    let insertions: [HomeInsertItem]
    let updates: [HomeUpdateItem]
}

public enum ListViewItemOperationDirectionHint {
    case Up
    case Down
}

struct HomeDeleteItem {
    public let index: Int
    public let directionHint: ListViewItemOperationDirectionHint?
    
    public init(index: Int, directionHint: ListViewItemOperationDirectionHint?) {
        self.index = index
        self.directionHint = directionHint
    }
}

struct HomeInsertItem {
    public let index: Int
    public let previousIndex: Int?
    public let directionHint: ListViewItemOperationDirectionHint?
    public let forceAnimateInsertion: Bool
    
    public init(index: Int,
                previousIndex: Int?,
                directionHint: ListViewItemOperationDirectionHint?,
                forceAnimateInsertion: Bool = false) {
        self.index = index
        self.previousIndex = previousIndex
        self.directionHint = directionHint
        self.forceAnimateInsertion = forceAnimateInsertion
    }
}

struct HomeUpdateItem {
    public let index: Int
    public let previousIndex: Int
    public let directionHint: ListViewItemOperationDirectionHint?
    
    public init(index: Int,
                previousIndex: Int,
                directionHint: ListViewItemOperationDirectionHint?) {
        self.index = index
        self.previousIndex = previousIndex
        self.directionHint = directionHint
    }
}
