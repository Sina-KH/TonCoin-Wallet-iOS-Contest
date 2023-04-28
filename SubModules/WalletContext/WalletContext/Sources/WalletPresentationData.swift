import Foundation
import UIKit
import SwiftSignalKit

public enum WalletTimeFormat {
    case regular
    case military
}

public enum WalletDateFormat {
    case monthFirst
    case dayFirst
}

public struct WalletPresentationDateTimeFormat: Equatable {
    public let timeFormat: WalletTimeFormat
    public let dateFormat: WalletDateFormat
    public let dateSeparator: String
    public let decimalSeparator: String
    public let groupingSeparator: String
    
    public init(timeFormat: WalletTimeFormat, dateFormat: WalletDateFormat, dateSeparator: String, decimalSeparator: String, groupingSeparator: String) {
        self.timeFormat = timeFormat
        self.dateFormat = dateFormat
        self.dateSeparator = dateSeparator
        self.decimalSeparator = decimalSeparator
        self.groupingSeparator = groupingSeparator
    }
}

private final class WalletThemeResourceCacheHolder {
    var images: [Int32: UIImage] = [:]
}

enum WalletThemeResourceKey: Int32 {
    case itemListCornersBoth
    case itemListCornersTop
    case itemListCornersBottom
    case itemListClearInputIcon
    case itemListDisclosureArrow
    case navigationShareIcon
    case transactionLockIcon
    
    case clockMin
    case clockFrame
}

func walletStringsFormattedNumber(_ count: Int32, _ groupingSeparator: String = "") -> String {
    let string = "\(count)"
    if groupingSeparator.isEmpty || abs(count) < 1000 {
        return string
    } else {
        var groupedString: String = ""
        for i in 0 ..< Int(ceil(Double(string.count) / 3.0)) {
            let index = string.count - Int(i + 1) * 3
            if !groupedString.isEmpty {
                groupedString = groupingSeparator + groupedString
            }
            groupedString = String(string[string.index(string.startIndex, offsetBy: max(0, index)) ..< string.index(string.startIndex, offsetBy: index + 3)]) + groupedString
        }
        return groupedString
    }
}

public func topViewController() -> UIViewController? {
    if #available(iOS 13.0, *) {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
    } else {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }

            return topController
        }
    }

    return nil
}
