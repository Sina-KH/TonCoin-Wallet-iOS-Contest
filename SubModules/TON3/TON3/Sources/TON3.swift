//
//  Created by Anton Spivak
//

import Foundation
import JavaScriptCore
import CryptoSwift
import SwiftyJS

public struct TON3 {
    
    @JSActor
    public class Cell {
        
        fileprivate let js: JSValue
        
        fileprivate init(_ value: JSValue) {
            js = value
        }
        
        public init(boc: [UInt8]) throws {
            let bundle = try JSBundle.ton3
            let exports = bundle.exports()
            let klass = exports?.objectForKeyedSubscript("Cell3")
            
            guard let value = klass?.construct(withArguments: [boc])
            else {
                throw JSError(.executionFailed)
            }
            
            js = value
        }
        
        public func data() throws -> [UInt8] {
            guard let value = js.invokeMethod("data", withArguments: [])?.toString()
            else {
                throw JSError(.executionFailed)
            }
            
            return [UInt8](hex: value)
        }
    }
    
    @JSActor
    public class Builder {
        
        fileprivate let js: JSValue
        
        public init() throws {
            let bundle = try JSBundle.ton3
            let exports = bundle.exports()
            let klass = exports?.objectForKeyedSubscript("Builder3")
            
            guard let value = klass?.construct(withArguments: [])
            else {
                throw JSError(.executionFailed)
            }
            
            js = value
        }
        
        public func store(_ value: UInt8) {
            js.invokeMethod("storeUint", withArguments: [value, 8])
        }
        
        public func store(_ value: UInt32) {
            js.invokeMethod("storeUint", withArguments: [value, 32])
        }
        
        public func store(_ value: UInt64) {
            js.invokeMethod("storeUint", withArguments: [value, 64])
        }
        
        public func store(_ value: [UInt8]) {
            js.invokeMethod("storeBytes", withArguments: [value])
        }
        
        public func store(_ bit: Bool) {
            js.invokeMethod("storeBit", withArguments: [bit ? 1 : 0])
        }
        
        public func store(_ value: Cell) {
            js.invokeMethod("storeRef", withArguments: [value.js])
        }
        
        public func store(_ value: String) {
            js.invokeMethod("storeString", withArguments: [value])
        }
        
        public func store(address: [UInt8], workchain: Int32) {
            js.invokeMethod("storeAddress", withArguments: [address, workchain])
        }
        
        public func store(coins: Int64) {
            js.invokeMethod("storeCoins", withArguments: [coins])
        }
        
        public func cell() throws -> Cell {
            guard let value = js.invokeMethod("cell", withArguments: [false])
            else {
                throw JSError(.executionFailed)
            }
            
            return Cell(value)
        }
        
        public func boc() throws -> String {
            guard let value = js.invokeMethod("boc", withArguments: [])?.toString()
            else {
                throw JSError(.executionFailed)
            }
            
            return value
        }
    }
    
    // MARK: Messages
    
    @JSActor
    public static func initial(
        code: [UInt8],
        data: [UInt8]?
    ) async throws -> String {
        let bundle = try JSBundle.ton3
        let exports = bundle.exports()
        let function = exports?.objectForKeyedSubscript("initial")
        
        var arguments: [Any] = [
            code
        ]
        
        if let data = data {
            arguments.append(data)
        }
        
        guard let value = function?.call(withArguments: arguments)?.toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return value
    }
    
    @JSActor
    public static func address(
        boc: [UInt8]
    ) async throws -> String {
        let bundle = try JSBundle.ton3
        let exports = bundle.exports()
        let function = exports?.objectForKeyedSubscript("address")
        
        guard let value = function?.call(withArguments: [boc])?.toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return value
    }
    
    @JSActor
    public static func transfer(
        external: [UInt8],
        workchain: Int32,
        address: [UInt8],
        amount: Int64,
        bounceable: Bool,
        payload: [UInt8]? = nil,
        state: [UInt8]? = nil
    ) async throws -> [UInt8] {
        let bundle = try JSBundle.ton3
        let exports = bundle.exports()
        let function = exports?.objectForKeyedSubscript("transfer")
        
        let arguments: [Any] = [
            external,
            workchain,
            address,
            amount,
            bounceable,
            (payload ?? NSNull()),
            (state ?? NSNull()),
        ]
        
        guard let value = function?.call(withArguments: arguments)?.toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return [UInt8](hex: value)
    }
    
    // MARK: BOC
    
    @JSActor
    public static func createBOCWithSignature(
        data: Data,
        signature: [UInt8]
    ) async throws -> Data {
        let bundle = try JSBundle.ton3
        let js = bundle.exports()
        let function = js?.objectForKeyedSubscript("createBOCWithSignature")
        
        guard let value = function?.call(withArguments: [data.toHexString(), signature]).toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return Data(hex: value)
    }
    
    @JSActor
    public static func createBOCHash(
        data: Data
    ) async throws -> Data {
        let bundle = try JSBundle.ton3
        let js = bundle.exports()
        let function = js?.objectForKeyedSubscript("createBOCHash")
        
        guard let value = function?.call(withArguments: [data.toHexString()]).toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return Data(hex: value)
    }
    
    @JSActor
    public static func getBOCRootCellData(
        data: Data
    ) async throws -> Data {
        let bundle = try JSBundle.ton3
        let js = bundle.exports()
        let function = js?.objectForKeyedSubscript("getBOCRootCellData")
        
        guard let value = function?.call(withArguments: [data.toHexString()]).toString()
        else {
            throw JSError(.executionFailed)
        }
        
        return Data(hex: value)
    }
}
