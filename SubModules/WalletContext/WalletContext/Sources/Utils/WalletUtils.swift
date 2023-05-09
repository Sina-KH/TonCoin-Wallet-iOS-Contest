//
//  WalletUtils.swift
//  WalletContext
//
//  Created by Sina on 4/21/23.
//

import Foundation

public func walletVersionString(version: Int) -> String {
    switch version {
    case 31:
        return "v3R1"
    case 32:
        return "v3R2"
    case 42:
        return "v4R2"
    default:
        return ""
    }
}

// TODO:: Read from WStrings?
fileprivate let decimalSeparator = "."

public let walletAddressLength: Int = 48
public let walletTextLimit: Int = 512

// format address to 2-line text
public func formatAddress(_ address: String) -> String {
    var address = address
    address.insert("\n", at: address.index(address.startIndex, offsetBy: address.count / 2))
    return address
}

public func formatStartEndAddress(_ address: String) -> String {
    return "\(address.prefix(4))...\(address.suffix(4))"
}

// create deeplink for wallet address with optional amount and comment properties
public func walletInvoiceUrl(address: String, amount: String? = nil, comment: String? = nil) -> String {
    var arguments = ""
    if let amount = amount, !amount.isEmpty {
        arguments += arguments.isEmpty ? "?" : "&"
        arguments += "amount=\(amountValue(amount))"
    }
    if let comment = comment, !comment.isEmpty {
        arguments += arguments.isEmpty ? "?" : "&"
        arguments += "text=\(urlEncodedStringFromString(comment))"
    }
    return "ton://transfer/\(address)\(arguments)"
}

private let maxIntegral: Int64 = Int64.max / 1000000000

public func amountValue(_ string: String) -> Int64 {
    let string = string.replacingOccurrences(of: ",", with: ".")
    if let range = string.range(of: ".") {
        let integralPart = String(string[..<range.lowerBound])
        let fractionalPart = String(string[range.upperBound...])
        let string = integralPart + fractionalPart + String(repeating: "0", count: max(0, 9 - fractionalPart.count))
        return Int64(string) ?? 0
    } else if let integral = Int64(string) {
        if integral > maxIntegral {
            return 0
        }
        return integral * 1000000000
    }
    return 0
}

// format amount into string with separator
public func formatBalanceText(_ value: Int64) -> String {
    var balanceText = "\(abs(value))"
    while balanceText.count < 10 {
        balanceText.insert("0", at: balanceText.startIndex)
    }
    balanceText.insert(contentsOf: decimalSeparator, at: balanceText.index(balanceText.endIndex, offsetBy: -9))
    while true {
        if balanceText.hasSuffix("0") {
            if balanceText.hasSuffix("\(decimalSeparator)0") {
                balanceText.removeLast()
                balanceText.removeLast()
                break
            } else {
                balanceText.removeLast()
            }
        } else {
            break
        }
    }
    /*if value < 0 {
        balanceText.insert("-", at: balanceText.startIndex)
    }*/
    return balanceText
}

// timestamp into string
public func stringForTimestamp(timestamp: Int32, local: Bool = true) -> String {
    var t = Int(timestamp)
    var timeinfo = tm()
    if local {
        localtime_r(&t, &timeinfo)
    } else {
        gmtime_r(&t, &timeinfo)
    }
    
    return stringForShortTimestamp(hours: timeinfo.tm_hour, minutes: timeinfo.tm_min)
}

public func stringForShortTimestamp(hours: Int32, minutes: Int32) -> String {
    let hourString: String = hours < 10 ? "0\(hours)" : "\(hours)"
    /*if hours == 0 {
        hourString = "12"
    } else if hours > 12 {
        hourString = "\(hours - 12)"
    } else {
        hourString = "\(hours)"
    }*/

    /*let periodString: String
    if hours >= 12 {
        periodString = "PM"
    } else {
        periodString = "AM"
    }*/
    if minutes >= 10 {
        return "\(hourString):\(minutes)"// \(periodString)"
    } else {
        return "\(hourString):0\(minutes)"// \(periodString)"
    }
}

// check if address is valid
private let invalidAddressCharacters = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_=").inverted
public func isValidAddress(_ address: String, exactLength: Bool = false) -> Bool {
    if address.count > walletAddressLength || address.rangeOfCharacter(from: invalidAddressCharacters) != nil {
        return false
    }
    if exactLength && address.count != walletAddressLength {
        return false
    }
    return true
}
