//
//  Created by Anton Spivak
//

import Foundation

public final class Message {
    
    private enum QueryCondition: Int, Codable, Hashable {
        
        case ready = 1
        case invalid = 2
        case sended = 3
    }
    
    private let queryID: Int64
    private var queryCondition: QueryCondition
    
    public let destination: Address
    public let initial: Contract.InitialCondition?
    
    public let body: BOC
    public let bodyHash: Data
    
//    public init(
//        destination: Address,
//        initial: Contract.InitialCondition?,
//        body: BOC
//    ) async throws {
//        let query = try await wrapper.prepareQueryWithDestinationAddress(
//            destination.rawValue,
//            initialStateCode: initial?.kind.rawValue.data,
//            initialStateData: initial?.data,
//            body: body.data
//        )
//        
//        self.queryID = query.queryID
//        self.queryCondition = .ready
//        
//        self.destination = destination
//        self.initial = initial
//        self.body = body
//        self.bodyHash = query.bodyHash
//    }
//    
//    deinit {
//        guard queryCondition == .ready
//        else {
//            return
//        }
//        
//        let queryID = self.queryID
//        Task {
//            try? await wrapper.remove(
//                preparedQueryID: queryID
//            )
//        }
//    }
//    
//    /// Remove stored local copy of query
//    public func invalidate() async throws {
//        switch queryCondition {
//        case .ready:
//            break
//        case .invalid:
//            return
//        case .sended:
//            throw MessageError.messageSended
//        }
//        
//        try await wrapper.remove(
//            preparedQueryID: queryID
//        )
//        
//        queryCondition = .invalid
//    }
//    
//    /// Returns fees for message
//    public func fees() async throws -> Currency {
//        guard queryCondition == .ready || queryCondition == .sended
//        else {
//            throw MessageError.messageInvalidated
//        }
//        
//        let fees = try await wrapper.estimateFees(
//            preparedQueryID: queryID
//        )
//        
//        var value = Int64(0)
//        value += fees.sourceFees.fwdFee
//        value += fees.sourceFees.gasFee
//        value += fees.sourceFees.inFwdFee
//        value += fees.sourceFees.storageFee
//        return Currency(value: value)
//    }
//    
//    /// Send message to network
//    public func send() async throws {
//        switch queryCondition {
//        case .ready:
//            break
//        case .invalid:
//            throw MessageError.messageInvalidated
//        case .sended:
//            throw MessageError.messageSended
//        }
//
//        try await wrapper.send(
//            preparedQueryID: queryID
//        )
//        
//        queryCondition = .sended
//    }
}

extension Message: Codable {}
extension Message: Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(queryID)
    }
    
    public static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.queryID == rhs.queryID
    }
}
