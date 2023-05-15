//
//  Created by Anton Spivak
//

import Foundation


public extension Transaction {
    
    struct Message {
        
        public let sourceAccountAddress: ConcreteAddress?
        public let destinationAccountAddress: ConcreteAddress?
        
        public let value: Currency
        public let fees: Currency
        
        public let body: Content
        public let bodyHash: Data
        
        public var isEncrypted: Bool {
            switch body {
            case .encrypted:
                return true
            default:
                return false
            }
        }
        
        public init(
            sourceAccountAddress: ConcreteAddress?,
            destinationAccountAddress: ConcreteAddress?,
            value: Currency,
            fees: Currency,
            body: Content,
            bodyHash: Data
        ) {
            self.sourceAccountAddress = sourceAccountAddress
            self.destinationAccountAddress = destinationAccountAddress
            
            self.value = value
            self.fees = fees
            
            self.body = body
            self.bodyHash = bodyHash
        }
        
//        internal init?(
//            message: GTTransactionMessage?
//        ) {
//            guard let message = message
//            else {
//                return nil
//            }
//            
//            self.sourceAccountAddress = ConcreteAddress(string: message.source)
//            self.destinationAccountAddress = ConcreteAddress(string: message.destination)
//            
//            self.value = Currency(value: message.value)
//            self.fees = Currency(value: message.fwdFee + message.ihrFee)
//            
//            self.body = .from(contents: message.contents)
//            self.bodyHash = message.bodyHash
//        }
        
//        public func unencryptContentIfNeccessary(
//            with key: Key,
//            userPassword: Data
//        ) async throws -> Content {
//            switch body {
//            case let .encrypted(data, sourceAccountAddress):
//                let decrypted = try await wrapper.decryptMessagesWithKey(
//                    GTTONKey(publicKey: key.publicKey, encryptedSecretKey: key.encryptedSecretKey),
//                    userPassword: userPassword,
//                    messages: [
//                        GTEncryptedData(
//                            sourceAccountAddress: sourceAccountAddress,
//                            data: data
//                        )
//                    ]
//                )
//                
//                guard let first = decrypted.first
//                else {
//                    throw UndefinedError()
//                }
//                
//                return .from(contents: first)
//            default:
//                return body
//            }
//        }
    }
}

extension Transaction.Message: Codable {}
extension Transaction.Message: Hashable {}
