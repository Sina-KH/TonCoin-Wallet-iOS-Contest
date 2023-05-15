//
//  Created by Anton Spivak
//

import Foundation

public struct JSError {
    
    public struct Code: RawRepresentable, Hashable {

        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    public let code: Code
    
    public init(_ code: Code) {
        self.code = code
    }
}

extension JSError: LocalizedError {
    
    public var errorDescription: String? {
        switch code {
        case .moduleNotFound:
            return "Module not found"
        case .moduleNotFound:
            return "Method execution failed"
        default:
            return nil
        }
    }
}

public extension JSError.Code {
    
    static let moduleNotFound = JSError.Code(rawValue: 22000)
    static let executionFailed = JSError.Code(rawValue: 22001)
}
