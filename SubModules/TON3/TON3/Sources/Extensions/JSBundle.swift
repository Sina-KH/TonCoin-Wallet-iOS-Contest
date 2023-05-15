
//
//  Created by Anton Spivak
//

import Foundation
import JavaScriptCore
import SwiftyJS

@JSActor
internal extension JSBundle {
    
    private static var _ton3: JSBundle?
    static var ton3: JSBundle {
        get throws {
            let bundle: JSBundle
            if let _ton3 = _ton3 {
                bundle = _ton3
            } else {
                bundle = try JSBundle(url: ton3URL(), with: { context in
                    let value = JSValue(newObjectIn: context)
                    value?.setObject(TON3StringToBytes as (@convention(block) (String) -> [UInt8]), forKeyedSubscript: "TON3StringToBytes")
                    value?.setObject(TON3BytesToString as (@convention(block) ([UInt8]) -> String?), forKeyedSubscript: "TON3BytesToString")
                    
                    value?.setObject(TON3SHA256 as (@convention(block) ([UInt8]) -> String?), forKeyedSubscript: "TON3SHA256")
                    value?.setObject(TON3SHA512 as (@convention(block) ([UInt8]) -> String?), forKeyedSubscript: "TON3SHA512")
                    
                    value?.setObject(TON3BytesToBase64 as (@convention(block) ([UInt8]) -> String), forKeyedSubscript: "TON3BytesToBase64")
                    value?.setObject(TON3Base64ToBytes as (@convention(block) (String) -> [UInt8]), forKeyedSubscript: "TON3Base64ToBytes")
                    return value
                })
                _ton3 = bundle
            }
            return bundle
        }
    }
    
    private static func ton3URL() -> URL {
        guard let url = Bundle.main.url(forResource: "ton3-core", withExtension: "bundle")
        else {
            fatalError("Can't locate ton3-core.bundle")
        }
        return url
    }
}
