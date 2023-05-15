//
//  Created by Anton Spivak
//

import Foundation

/// Should be used insted of `withCheckedThrowingContinuation` for retrying calls
///
/// - parameter update:Should be `true` if request did requre network updates
/// - parameter pretry: Called before each retry (`attemptNumber` will be 0 for initial attempt)
/// - warning: Should be called before requests
/// - Throws: TODO
internal func retryingIfAvailable<T>(
    function: String = #function,
    pretry: @Sendable @escaping (_ attemptNumber: Int) async throws -> (),
    _ body: (CheckedContinuation<T, Error>) -> Void
) async throws -> T {
    do {
        try Task<Never, Never>.checkCancellation()
        try await pretry(-1)
        
        try Task<Never, Never>.checkCancellation()
        return try await withCheckedThrowingContinuation(function: function, body)
    } catch let error as RetryableError {
        guard error.maximumRetryCount > 0
        else {
            throw error
        }
        
        return try await retrying(
            function: function,
            maximumRetryCount: error.maximumRetryCount,
            pretry: pretry,
            body
        )
    } catch {
        throw error
    }
}

private func retrying<T>(
    function: String = #function,
    maximumRetryCount: Int,
    pretry: @Sendable @escaping (_ attemptNumber: Int) async throws -> (),
    _ body: (CheckedContinuation<T, Error>) -> Void
) async throws -> T {
    for i in 0..<max(maximumRetryCount - 1, 0) { // `-1` beacuse at and of function we have last attempt
        do {
            try Task<Never, Never>.checkCancellation()
            try await pretry(i + 1) // 0 was in initial attempt
            
            try Task<Never, Never>.checkCancellation()
            return try await withCheckedThrowingContinuation(function: function, body)
        } catch {
            let maximumDelay = TimeInterval(10) // 10 second
            let calculatedDelay = pow(2.0, TimeInterval(i) / 2)
            let saltDelay = TimeInterval.random(in: 0.1 ... 0.9)
            let delay = min(calculatedDelay + saltDelay, maximumDelay)
            
            try await Task<Never, Never>.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            continue
        }
    }
    
    try Task<Never, Never>.checkCancellation()
    try await pretry(maximumRetryCount)
    
    try Task<Never, Never>.checkCancellation()
    return try await withCheckedThrowingContinuation(function: function, body)
}
