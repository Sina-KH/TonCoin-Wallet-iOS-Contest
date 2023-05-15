//
//  Created by Anton Spivak
//

import Foundation

import CryptoSwift

public struct Contract {
    
    public let info: Info
    public let address: Address
    
    /// Nil - contract kind is unknown
    public let kind: Kind?
    public let data: BOC
    
//    public init(
//        address: Address
//    ) async throws {
//        let state = try await wrapper.accountWithAddress(address.rawValue)
//
//        var lastTransactionID: Transaction.ID? = nil
//        if let _lastTransactionID = state.lastTransactionID {
//            lastTransactionID = Transaction.ID(
//                logicalTime: _lastTransactionID.logicalTime,
//                hash: _lastTransactionID.transactionHash
//            )
//        }
//
//        self.init(
//            address: address,
//            info: Info(
//                balance: Currency(value: state.balance),
//                synchronizationDate: Date(utimeInt64: state.synctime),
//                lastTransactionID: lastTransactionID
//            ),
//            kind: Kind(rawValue: BOC(code: state.code)),
//            data: BOC(code: state.data)
//        )
//    }
    
    public init(
        address: Address,
        info: Info,
        kind: Kind?,
        data: BOC
    ) {
        self.address = address
        self.info = info
        self.kind = kind
        self.data = data
    }
    
//    public func execute(
//        methodNamed: String,
//        arguments: [GTExecutionStackValue] = []
//    ) async throws -> ExecutionResult {
//        let localID = try await wrapper.accountLocalIDWithAccountAddress(address.rawValue)
//        let result = try await wrapper.accountLocalID(localID, runGetMethodNamed: methodNamed, arguments: arguments)
//        return ExecutionResult(code: result.code, stack: result.stack)
//    }
//
//    public func transactions(
//        after: Transaction.ID?
//    ) async throws -> [Transaction] {
//        // At this point we thinking that currently we have a `newest` state of contract
//        guard after != info.lastTransactionID
//        else {
//            return []
//        }
//
//        var transactions: [Transaction] = []
//        while true {
//            let startingFrom = transactions.last?.id ?? info.lastTransactionID
//            guard let startingFrom = startingFrom
//            else {
//                break
//            }
//
//            var next = try await self.transactions(startingFrom: startingFrom)
//            try Task.checkCancellation()
//
//            if transactions.last == next.first {
//                // First is last from old transactions
//                next = Array(next.dropFirst())
//            }
//
//            guard next.count > 1
//            else {
//                transactions = transactions + next
//                break
//            }
//
//            // after means that we need all transactions commited after it's date
//            if let after = after, let index = next.firstIndex(where: { $0.id == after }) {
//                transactions = transactions + Array(next[0..<index])
//                break
//            } else {
//                transactions = transactions + next
//            }
//        }
//        return transactions
//    }
//
//    public func transactions(
//        startingFrom last: Transaction.ID
//    ) async throws -> [Transaction] {
//        do {
//            return try await wrapper.transactionsForAccountAddress(
//                address.rawValue,
//                lastTransactionID: GTTransactionID(
//                    logicalTime: last.logicalTime,
//                    transactionHash: last.hash
//                )
//            ).map({ try Transaction(transaction: $0) })
//        } catch let error as LiteserverError {
//            switch error {
//            case .ltNotInDatabase:
//                // Do not throw error if server does not contain transactions
//                // Maybe this is not full node or smth
//                return []
//            default:
//                throw error
//            }
//        } catch {
//            throw error
//        }
//    }
}

extension Contract: Codable {}
extension Contract: Hashable {}
