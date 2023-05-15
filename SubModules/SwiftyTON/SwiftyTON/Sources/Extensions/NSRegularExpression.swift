//
//  Created by Anton Spivak
//

import Foundation

extension NSRegularExpression {
    public static var tonRawAddress: NSRegularExpression = {
        let pattern = "^(0|-1):([a-f0-9]{64}|[A-F0-9]{64})$"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern)
        else {
            fatalError(
                "Can't compose `NSRegularExpression` for pattern: \(pattern)"
            )
        }
        return regularExpression
    }()

    public static var tonDNSAddress: NSRegularExpression = {
        let pattern =
            "^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9](\\.ton|\\.t\\.me)$"
        guard let regularExpression = try? NSRegularExpression(pattern: pattern)
        else {
            fatalError(
                "Can't compose `NSRegularExpression` for pattern: \(pattern)"
            )
        }
        return regularExpression
    }()
}
