//
//  Created by Anton Spivak
//

import Foundation
import JavaScriptCore

@JSActor
public final class JSBundle {
    
    nonisolated public var name: String { url.lastPathComponent }
    nonisolated public let url: URL
    nonisolated public let bridge: JSValue
    
    private let virtualMachine: JSVirtualMachine
    private let context: JSContext
    
    private var module: JSModule
    
    public init(
        url: URL,
        with bridge: (_ context: JSContext) -> JSValue?
    ) throws {
        let indexJSURL = url.appendingPathComponent("index.js")
        
        let virtualMachine = JSVirtualMachine()!
        let context: JSContext = {
            let context = JSContext(virtualMachine: virtualMachine)!
            context.exceptionHandler = { context, value in
                guard let value = value
                else {
                    return
                }
                
                print("JSBundle: did handle error: \(value)")
            }
            return context
        }()
        
        self.url = url
        self.bridge = bridge(context) ?? JSValue(newObjectIn: context)
        self.module = try JSModule(fileURL: indexJSURL)
        
        self.virtualMachine = virtualMachine
        self.context = context
    }
    
    public func exports() -> JSValue? {
        loadIfNeeded()
        return module.exports?.value
    }
    
    // MARK: Private API
    
    func loadIfNeeded() {
        guard module.exports?.value == nil
        else {
            return
        }
        
        module.invoke(bundleURL: url, context: context, bridge: bridge)
    }
}
