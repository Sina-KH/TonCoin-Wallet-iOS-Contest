//
//  Created by Anton Spivak
//

import Foundation
import BigInt


public extension Contract {
    
    struct ExecutionResult {
        
        public let code: Int32
        public let stack: [Any]
        
        internal init(
            code: Int32, stack: [Any]
        ) {
            self.code = code
            self.stack = stack
        }
    }
}
//
//public extension Contract.ExecutionResult {
//
//    func map<T: GTExecutionStackValue>(
//        to types: (T.Type)
//    ) -> (T)? {
//        let mirror = Mirror(reflecting: types)
//        guard mirror.children.count <= stack.count
//        else {
//            return nil
//        }
//
//        guard let s0 = stack[0] as? T else { return nil }
//
//        return (s0)
//    }
//
//    func map<T: GTExecutionStackValue, Y: GTExecutionStackValue>(
//        to types: (T.Type, Y.Type)
//    ) -> (T, Y)? {
//        let mirror = Mirror(reflecting: types)
//        guard mirror.children.count <= stack.count
//        else {
//            return nil
//        }
//
//        guard let s0 = stack[0] as? T else { return nil }
//        guard let s1 = stack[1] as? Y else { return nil }
//
//        return (s0, s1)
//    }
//
//    func map<T: GTExecutionStackValue, Y: GTExecutionStackValue, U: GTExecutionStackValue>(
//        to types: (T.Type, Y.Type, U.Type)
//    ) -> (T, Y, U)? {
//        let mirror = Mirror(reflecting: types)
//        guard mirror.children.count <= stack.count
//        else {
//            return nil
//        }
//
//        guard let s0 = stack[0] as? T else { return nil }
//        guard let s1 = stack[1] as? Y else { return nil }
//        guard let s2 = stack[2] as? U else { return nil }
//
//        return (s0, s1, s2)
//    }
//
//    func map<T: GTExecutionStackValue, Y: GTExecutionStackValue, U: GTExecutionStackValue, I: GTExecutionStackValue>(
//        to types: (T.Type, Y.Type, U.Type, I.Type)
//    ) -> (T, Y, U, I)? {
//        let mirror = Mirror(reflecting: types)
//        guard mirror.children.count <= stack.count
//        else {
//            return nil
//        }
//
//        guard let s0 = stack[0] as? T else { return nil }
//        guard let s1 = stack[1] as? Y else { return nil }
//        guard let s2 = stack[2] as? U else { return nil }
//        guard let s3 = stack[3] as? I else { return nil }
//
//        return (s0, s1, s2, s3)
//    }
//
//    func map<T: GTExecutionStackValue, Y: GTExecutionStackValue, U: GTExecutionStackValue, I: GTExecutionStackValue, O: GTExecutionStackValue>(
//        to types: (T.Type, Y.Type, U.Type, I.Type, O.Type)
//    ) -> (T, Y, U, I, O)? {
//        let mirror = Mirror(reflecting: types)
//        guard mirror.children.count <= stack.count
//        else {
//            return nil
//        }
//
//        guard let s0 = stack[0] as? T else { return nil }
//        guard let s1 = stack[1] as? Y else { return nil }
//        guard let s2 = stack[2] as? U else { return nil }
//        guard let s3 = stack[3] as? I else { return nil }
//        guard let s4 = stack[4] as? O else { return nil }
//
//        return (s0, s1, s2, s3, s4)
//    }
//}
