//
//  Created by Anton Spivak
//

import Foundation
import CryptoSwift

internal func TON3StringToBytes(_ value: String) -> [UInt8] { value.bytes }
internal func TON3BytesToString(_ value: [UInt8]) -> String? { String(bytes: value, encoding: .utf8) }

internal func TON3SHA256(_ value: [UInt8]) -> String? { value.sha256().toHexString() }
internal func TON3SHA512(_ value: [UInt8]) -> String? { value.sha512().toHexString() }

internal func TON3BytesToBase64(_ value: [UInt8]) -> String { Data(value).base64EncodedString() }
internal func TON3Base64ToBytes(_ value: String) -> [UInt8] { Data(base64Encoded: value)?.bytes ?? [] }
