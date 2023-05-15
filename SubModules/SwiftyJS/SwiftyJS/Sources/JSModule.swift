//
//  Created by Anton Spivak
//

import Foundation
import JavaScriptCore

@JSActor
internal final class JSModule {
    
    internal let fileURL: URL
    internal let contents: String
    internal var exports: JSManagedValue? = nil
    
    nonisolated internal init(
        fileURL: URL
    ) throws {
        self.fileURL = fileURL
        self.contents = try String(contentsOf: fileURL, encoding: .utf8)
    }
    
    internal func invoke(
        bundleURL: URL,
        context: JSContext,
        bridge: JSValue
    ) {
        let value = JSModuleInvoke(
            module: self,
            bundleURL: bundleURL,
            context: context,
            bridge: bridge
        )
        
        exports = JSManagedValue(value: value, andOwner: self)
    }
}
