//
//  TransactionUtils.swift
//  WalletContext
//
//  Created by Sina on 4/29/23.
//

import WalletCore

extension WalletTransaction {
    
    public func extractAddress() -> String? {
        if self.transferredValueWithoutFees <= 0 {
            // sent
            if self.outMessages.isEmpty {
                return nil
            } else {
                for message in self.outMessages {
                    return message.destination
                }
            }
        } else {
            return inMessage?.source
        }
        return nil
    }
    
    public func extractAddressAndDescription() -> (String, String, Bool) { // address, description, descriptionIsMonospace
        var addressString = ""
        var descriptionString = ""
        var descriptionIsMonospace = false

        if self.transferredValueWithoutFees < 0 {
            // sent
            if self.outMessages.isEmpty {
                if self.isInitialization {
                    addressString = WStrings.Wallet_Home_InitTransaction.localized
                } else {
                    addressString = WStrings.Wallet_Home_UnknownTransaction.localized
                }
            } else {
                for message in self.outMessages {
                    if !addressString.isEmpty {
                        addressString.append("\n")
                    }
                    addressString.append(formatAddress(message.destination))
                    
                    if !descriptionString.isEmpty {
                        descriptionString.append("\n")
                    }
                    switch message.contents {
                    case .raw:
                        break
                    case .encryptedText:
                        descriptionIsMonospace = true
                        break
                    case let .plainText(text):
                        descriptionString.append(text)
                    }
                }
            }
        } else {
            // received
            addressString = formatAddress(self.inMessage?.source ?? "")
            if let contents = self.inMessage?.contents {
                switch contents {
                case .raw:
                    descriptionString = ""
                case .encryptedText:
                    descriptionString = ""
                    descriptionIsMonospace = true
                case let .plainText(text):
                    descriptionString = text
                }
            }
        }
        
        return (addressString, descriptionString, descriptionIsMonospace)
    }
    
    public var hashPreview: String {
        let hash = transactionId.transactionHash.base64EncodedString()
        if hash.count < 14 {
            return hash
        }
        return"\(hash.prefix(5))...\(hash.suffix(5))"
    }
}

extension PendingWalletTransaction {
    
    public func extractAddressAndDescription() -> (String, String, Bool) { // address, description, descriptionIsMonospace
        return (self.address, String(data: self.comment, encoding: .utf8) ?? "", false)
    }
    
    public var hashPreview: String {
        let hash = self.bodyHash.base64EncodedString()
        if hash.count < 14 {
            return hash
        }
        return"\(hash.prefix(5))...\(hash.suffix(5))"
    }
}
