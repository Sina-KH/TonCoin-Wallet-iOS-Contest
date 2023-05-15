//
//  Created by Anton Spivak
//

import Foundation

public enum LiteserverError {
    
    case generic(underlyingError: Error)
    case ltNotInDatabase
    case cancelled
    
    internal init(underlyingError: Error) {
        let text = underlyingError.localizedDescription.lowercased()
        if text.hasSuffix("lt not in db") {
            self = .ltNotInDatabase
        } else {
            self = .generic(underlyingError: underlyingError)
        }
    }
}

extension LiteserverError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case let .generic(underlyingError):
            return "Did receive an liteserver error: \(underlyingError.localizedDescription)."
        case .ltNotInDatabase:
            return "This seems to be currently all we could find at public blockhain node."
        case .cancelled:
            return "Looks like request was cancelled."
        }
    }
}

extension LiteserverError: RetryableError {
    
    public var maximumRetryCount: Int {
        switch self {
        case .cancelled, .generic:
            return 3
        case .ltNotInDatabase:
            return 1
        }
    }
}
