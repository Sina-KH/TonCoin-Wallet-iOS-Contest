//
//  StringUtils.swift
//  WalletContext
//
//  Created by Sina on 5/11/23.
//

import Foundation

public extension Data {
  /// A hexadecimal string representation of the bytes.
  func hexEncodedString() -> String {
    let hexDigits = Array("0123456789abcdef".utf16)
    var hexChars = [UTF16.CodeUnit]()
    hexChars.reserveCapacity(count * 2)

    for byte in self {
      let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
      hexChars.append(hexDigits[index1])
      hexChars.append(hexDigits[index2])
    }

    return String(utf16CodeUnits: hexChars, count: hexChars.count)
  }
}
