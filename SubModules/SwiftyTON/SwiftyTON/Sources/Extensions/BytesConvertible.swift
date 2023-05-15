//
//  Created by Anton Spivak
//

import Foundation

public protocol BytesConvertible {
    
    var bytes: [UInt8] { get }
}

extension BytesConvertible {
    
    func convert<T: FixedWidthInteger>(endian: T) -> [UInt8] {
        var _endian = endian
        let size = MemoryLayout<T.Type>.size
        let pointee = withUnsafePointer(to: &_endian, { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: size, { pointer in
                UnsafeBufferPointer(start: pointer, count: size)
            })
        })
        return [UInt8](pointee)
    }
}

extension FixedWidthInteger {
    
    public var bytes: [UInt8] {
        var endian = self.littleEndian
        let size = MemoryLayout<Self>.size
        let pointee = withUnsafePointer(to: &endian, { pointer in
            pointer.withMemoryRebound(to: UInt8.self, capacity: size, { pointer in
                UnsafeBufferPointer(start: pointer, count: size)
            })
        })
        return [UInt8](pointee)
    }
}
