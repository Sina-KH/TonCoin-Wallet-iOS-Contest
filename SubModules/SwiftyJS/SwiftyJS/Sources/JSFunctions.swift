//
//  Created by Anton Spivak
//

import Foundation
import JavaScriptCore

@JSActor
internal func JSModuleInvoke(
    module: JSModule,
    bundleURL: URL,
    context: JSContext,
    bridge: JSValue
) -> JSValue? {
    let moduleFileURL = module.fileURL
    let block: @convention(block) (String) -> JSValue? = { (_ requireName: String) -> JSValue? in
        switch requireName {
        case "swiftyjs":
            return bridge
        default:
            do {
                guard let fileURL = JSModuleResolve(
                    bundleDirectoryURL: bundleURL,
                    callerDirectoryURL: moduleFileURL.deletingLastPathComponent(),
                    requireNamed: requireName
                ) else {
                    throw JSError(.moduleNotFound)
                }
                
                let module = try JSModule(fileURL: fileURL)
                let exports = JSModuleInvoke(
                    module: module,
                    bundleURL: bundleURL,
                    context: context,
                    bridge: bridge
                )
                
                return exports
            } catch {
                return nil
            }
        }
    }
    
    let _module = JSValue(newObjectIn: context)
    _module?.setObject(JSValue(newObjectIn: context), forKeyedSubscript: "exports")
    
    guard let exports = JSValue(newObjectIn: context),
          let require = JSValue(object: block, in: context),
          let _module = _module
    else {
        return nil
    }
    
    
    let script = "(function(exports, require, module) {\n\n\(module.contents)\n\n});"
    let arguments = [exports, require, _module]
    context.evaluateScript(script, withSourceURL: module.fileURL).call(withArguments: arguments)
    
    if exports.toDictionary().isEmpty {
        return _module.objectForKeyedSubscript("exports")
    } else {
        return exports
    }
}

@JSActor
internal func JSModuleResolve(
    bundleDirectoryURL: URL,
    callerDirectoryURL: URL,
    requireNamed: String
) -> URL? {
    let bundleURL = bundleDirectoryURL.appendingPathComponent(requireNamed).standardized
    let nodeURL = bundleDirectoryURL.appendingPathComponent("node_modules/\(requireNamed)").standardized
    let callerURL = callerDirectoryURL.appendingPathComponent(requireNamed).standardized
    
    if let url = JSModuleIndexJSIfPresented(fileURL: bundleURL) {
        return url
    } else if let url = JSModuleIndexJSIfPresented(fileURL: nodeURL) {
        return url
    } else if let url = JSModuleIndexJSIfPresented(fileURL: callerURL) {
        return url
    } else {
        return nil
    }
}

@JSActor
private let fileManager = FileManager.default

@JSActor
private func JSModuleIndexJSIfPresented(fileURL: URL) -> URL? {
    let indexJSURL = fileURL.appendingPathComponent("index.js")
    if fileManager.fileExists(atPath: indexJSURL.relativePath, isDirectory: nil) {
        return indexJSURL
    }
    
    let nameJSURL = fileURL.appendingPathComponent({
        var lastPathComponent = fileURL.lastPathComponent
        if !lastPathComponent.hasSuffix(".js") {
            lastPathComponent = lastPathComponent.appending(".js")
        }
        return lastPathComponent
    }())
    
    if fileManager.fileExists(atPath: nameJSURL.relativePath, isDirectory: nil) {
        return nameJSURL
    }
    
    let moduleJSURL = fileURL.appendingPathExtension("js")
    if fileManager.fileExists(atPath: moduleJSURL.relativePath, isDirectory: nil) {
        return moduleJSURL
    }
    
    return nil
}
