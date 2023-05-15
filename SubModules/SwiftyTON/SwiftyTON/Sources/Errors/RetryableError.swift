//
//  Created by Anton Spivak
//

import Foundation

public protocol RetryableError: Error {
    
    var maximumRetryCount: Int { get }
}
