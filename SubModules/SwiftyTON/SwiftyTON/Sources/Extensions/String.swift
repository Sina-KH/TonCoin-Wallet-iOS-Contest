//
//  Created by Anton Spivak
//

import Foundation

extension String {
    
    /// Minify JSON sctring (remove newlines, whitespaces and etc.)
    ///
    /// - note: http://stackoverflow.com/questions/8913138/
    /// - note: https://developer.apple.com/reference/foundation/nsregularexpression#//apple_ref/doc/uid/TP40009708-CH1-SW46
    internal var JSONMinify: String {
        let pattern = "(\"(?:[^\"\\\\]|\\\\.)*\")|\\s+"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            
            let mod = regex.stringByReplacingMatches(
                in: self,
                options: .withTransparentBounds,
                range: NSMakeRange(0, count),
                withTemplate: "$1"
            )
            
            return mod
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\t", with: "")
                .replacingOccurrences(of: "\r", with: "")
        } else {
            return self
        }
    }
}

extension String {
    
    /// Converts a base64-url encoded string to a base64 encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLUnescaped() -> String {
        let replaced = replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        /// https://stackoverflow.com/questions/43499651/decode-base64url-to-base64-swift
        let padding = replaced.count % 4
        if padding > 0 {
            return replaced + String(repeating: "=", count: 4 - padding)
        } else {
            return replaced
        }
    }

    /// Converts a base64 encoded string to a base64-url encoded string.
    ///
    /// https://tools.ietf.org/html/rfc4648#page-7
    public func base64URLEscaped() -> String {
        return replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
