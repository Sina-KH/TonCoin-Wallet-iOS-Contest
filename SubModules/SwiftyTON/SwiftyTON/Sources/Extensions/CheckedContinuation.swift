//
//  Created by Anton Spivak
//

import Foundation


extension CheckedContinuation where E == Swift.Error {
    
//    public func resume(throwingSwiftyTONError error: E?) {
//        guard let error = error
//        else {
//            resume(throwing: UndefinedError())
//            return
//        }
//        
//        let errorDescription = error.localizedDescription.lowercased()
//        if (error as NSError).code == GTTONErrorCodeCancelled {
//            // This error generated when task was cancelled by the code, just skip
//            resume(throwing: error)
//        } else if errorDescription.contains("cancelled") {
//            resume(throwing: LiteserverError.cancelled)
//        } else if errorDescription.hasPrefix("lite_server_") {
//            resume(throwing: LiteserverError(underlyingError: error))
//        } else {
//            resume(throwing: error)
//        }
//    }
}
