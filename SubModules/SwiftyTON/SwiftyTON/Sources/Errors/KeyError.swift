//
//  Created by Anton Spivak
//

import Foundation

public enum KeyError: LocalizedError {
    
    case invalidPublicKey
    case incorrectCRC16Hash
    
    case notPublicByte
    case notED25519Byte
}
