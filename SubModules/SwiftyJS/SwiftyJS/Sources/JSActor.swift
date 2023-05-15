//
//  Created by Anton Spivak
//

import Foundation

@globalActor
public actor JSActor: GlobalActor {
    
    public static var shared = JSDispatchActor(dispatchQueue: DispatchQueue(label: "swiftyjs.actor"))
}

public final actor JSDispatchActor: Actor {
    
    private let executor: JSDispatchExecutor

    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        executor.asUnownedSerialExecutor()
    }

    public init(dispatchQueue: DispatchQueue) {
        executor = JSDispatchExecutor(dispatchQueue: dispatchQueue)
    }
}

public final class JSDispatchExecutor: SerialExecutor {
    
    let dispatchQueue: DispatchQueue

    init(dispatchQueue: DispatchQueue) {
        self.dispatchQueue = dispatchQueue
    }

    public func enqueue(_ job: UnownedJob) {
        let unownedSerialExecutor = asUnownedSerialExecutor()
        dispatchQueue.async {
            job._runSynchronously(on: unownedSerialExecutor)
        }
    }

    public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }
}

extension DispatchQueue: @unchecked Sendable {}
