//
//  Created by Anton Spivak
//

import Foundation


public extension Transaction.Message {
    
    enum Content {
        
        case text(value: String)
        case data(data: Data)
        case encrypted(data: Data, sourceAccountAddress: String)
        
//        internal static func from(
//            contents: GTTransactionMessageContents?
//        ) -> Transaction.Message.Content {
//            guard let contents = contents
//            else {
//                return .text(
//                    value: ""
//                )
//            }
//
//            if let content = contents as? GTTransactionMessageContentsRawData {
//                return .data(
//                    data: content.data
//                )
//            } else if let content = contents as? GTTransactionMessageContentsPlainText {
//                return .text(
//                    value: content.text
//                )
//            } else if let content = contents as? GTTransactionMessageContentsEncryptedText {
//                return .encrypted(
//                    data: content.encryptedData.data,
//                    sourceAccountAddress: content.encryptedData.sourceAccountAddress
//                )
//            } else {
//                return .text(
//                    value: ""
//                )
//            }
//        }
    }
}

extension Transaction.Message.Content: Codable {}
extension Transaction.Message.Content: Hashable {}
