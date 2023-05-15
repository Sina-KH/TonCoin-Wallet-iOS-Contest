//
//  Created by Anton Spivak
//

import Foundation

public enum ContractError {
    
    case unitialized
    case unknownContractType
    case notEnaughtBalance
}

extension ContractError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .unitialized:
            return "Contract currently unitialized"
        case .unknownContractType:
            return "Unknown account type"
        case .notEnaughtBalance:
            return "Not enaught balance"
        }
    }
}
