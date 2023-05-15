//
//  Created by Anton Spivak
//

import Foundation


public struct Transaction {
    
    public let id: ID
    public let date: Date
    public let storageFee: Currency
    public let otherFee: Currency
    public let `in`: Message?
    public let out: [Message]
    
    public init(
        id: ID,
        date: Date,
        storageFee: Currency,
        otherFee: Currency,
        `in`: Message?,
        out: [Message]
    ) {
        self.id = id
        self.date = date
        self.storageFee = storageFee
        self.otherFee = otherFee
        self.in = `in`
        self.out = out
    }
    
//    internal init(
//        transaction: GTTransaction
//    ) throws {
//        self.init(
//            id: ID(
//                logicalTime: transaction.transactionID.logicalTime,
//                hash: transaction.transactionID.transactionHash
//            ),
//            date: Date(utimeInt64: transaction.timestamp),
//            storageFee: Currency(value: transaction.storageFee),
//            otherFee: Currency(value: transaction.otherFee),
//            in: Message(message: transaction.inMessage),
//            out: transaction.outMessages.compactMap({ Message(message: $0) })
//        )
//    }
}

extension Transaction: Codable {}
extension Transaction: Hashable {}
