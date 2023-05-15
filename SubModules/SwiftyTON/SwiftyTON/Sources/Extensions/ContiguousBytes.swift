//
//  Created by Anton Spivak
//

import Foundation

public extension ContiguousBytes {
    
    func downcast<T>() throws -> T where T: FixedWidthInteger {
        let be: T = try withUnsafeBytes({ (_ value: UnsafeRawBufferPointer) in
            guard let address = value.baseAddress
            else {
                throw UndefinedError()
            }
            
            let pointer = address.assumingMemoryBound(to: T.self)
            return pointer.pointee
        })
        return T(bigEndian: be)
    }
}
