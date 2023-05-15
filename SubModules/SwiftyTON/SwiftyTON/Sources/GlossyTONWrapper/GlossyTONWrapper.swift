//
//  Created by Anton Spivak
//

import Foundation


internal final class GlossyTONWrapper: NSObject {
    
//    private struct Flags: OptionSet {
//        
//        let rawValue: Int
//        
//        static let initialized = Flags(rawValue: 1 << 0)
//    }
//    
//    private(set) var configuration: Configuration
//    
//    private let ton = GTTON()
//    private var flags: Flags = []
//    
//    init(configuration: Configuration) {
//        self.configuration = configuration
//        super.init()
//        self.ton.delegate = self
//    }
    
    /// Should be used insted of `withCheckedThrowingContinuation` for TON calls
    ///
    /// - parameter update: Should be `true` if request did requre network updates
    /// - warning: Should be called before all requests
    /// - Throws: TODO
//    fileprivate func request<T>(
//        id: GTRequestID,
//        function: String = #function,
//        _ body: (CheckedContinuation<T, Error>) -> Void
//    ) async throws -> T {
//        try await withTaskCancellationHandler(
//            handler: { [weak self] in
//                self?.ton.cancel(id)
//            },
//            operation: {
//                try await retryingIfAvailable(
//                    function: function,
//                    pretry: { attemptNumber in
//                        var configuration = await GTTONConfiguration.with(
//                            self.configuration,
//                            reload: attemptNumber > 0
//                        )
//
//                        do {
//                            try await self._initializeIfNeeded(configuration)
//                        } catch {
//                            configuration = await GTTONConfiguration.with(
//                                self.configuration,
//                                reload: true
//                            )
//
//                            try await self._initializeIfNeeded(configuration)
//                        }
//
//                        try await self._updateCurrentConfiguration(configuration)
//                        try await self._validateCurrentConfiguration()
//                    },
//                    body
//                )
//            }
//        )
//    }
    
    /// Initialize TON with given configuration
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
//    private func _initializeIfNeeded(
//        _ configuration: GTTONConfiguration
//    ) async throws {
//        guard !flags.contains(.initialized)
//        else {
//            return
//        }
//
//        // Here we don't need to retry
//        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
//            self.ton.initialize(
//                with: configuration,
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        self.flags.insert(.initialized)
//                        continuation.resume(returning: ())
//                    }
//                }
//            )
//        })
//    }
    
    /// Updates TON with given configuration
    ///
    /// - Parameter configuration: An network configuration
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
//    private func _updateCurrentConfiguration(
//        _ configuration: GTTONConfiguration
//    ) async throws {
//        // Here we don't need to retry
//        try await withCheckedThrowingContinuation({ (continuation: CheckedContinuation<(), Error>) in
//            self.ton.updateConfiguration(
//                configuration,
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                },
//                requestID: nil
//            )
//        })
//    }
    
    /// Validate current `Configuration` configuration and return `prefixWalletID`
    ///
    /// - Throws: TODO
    /// - Returns: prefixWalletID
//    @discardableResult
//    private func _validateCurrentConfiguration() async throws -> Int64 {
//        // Here we don't need to retry
//        try await withCheckedThrowingContinuation({ continuation in
//            self.ton.validateCurrentConfiguration(
//                completionBlock: { prefixWalletID, errror in
//                    if let error = errror {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: prefixWalletID)
//                    }
//                },
//                requestID: nil
//            )
//        })
//    }
}

// MARK: - GTTONDelegate

//extension GlossyTONWrapper: GTTONDelegate {
//
//    public func ton(
//        _ ton: GTTON,
//        didUpdateSynchronizationProgress progress: Double
//    ) {
//        AnnouncementCenter.shared.post(
//            announcement: AnnouncementSynchronization.self,
//            with: .init(progress: progress)
//        )
//    }
//}

extension GlossyTONWrapper {
    
//    internal func changeConfiguration(
//        to _configuration: Configuration
//    ) {
//        Task {
//            let configuration = await GTTONConfiguration.with(
//                _configuration,
//                reload: false
//            )
//
//            self.configuration = _configuration
//
//            try await self._updateCurrentConfiguration(configuration)
//            try await self._validateCurrentConfiguration()
//        }
//    }
}

// MARK: - API
    
extension GlossyTONWrapper {
    
    // MARK: - Keys
    
    /// Create and store key
    ///
    /// - Parameter userPassword: An user password
    /// - Parameter mnemonicPassword: An mnemonic password
    ///
    /// - Throws: TODO
    /// - Returns: Created `Key`
    ///
    /// - Warning: Key not be assotiated with address automatically
//    internal func createKeyWithUserPassword(
//        _ userPassword: Data,
//        mnemonicPassword: Data
//    ) async throws -> GTTONKey {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.createKey(
//                withUserPassword: userPassword,
//                mnemonicPassword: mnemonicPassword,
//                completionBlock: { key, error in
//                    if let key = key {
//                        continuation.resume(returning: key)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Import and store key
    ///
    /// - Parameter userPassword: An user password
    /// - Parameter mnemonicPassword: An mnemonic password
    /// - Parameter words: An 24 words
    ///
    /// - Throws: TODO
    /// - Returns: Imported `Key`
    ///
    /// - Warning: Key not be assotiated with address automatically
//    internal func importKeyWithUserPassword(
//        _ userPassword: Data,
//        mnemonicPassword: Data,
//        words: [String]
//    ) async throws -> GTTONKey {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.importKey(
//                withUserPassword: userPassword,
//                mnemonicPassword: mnemonicPassword,
//                words: words,
//                completionBlock: { key, error in
//                    if let key = key {
//                        continuation.resume(returning: key)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Removes key
    ///
    /// - Parameter key: key
    ///
    /// - Throws: TODO
    /// - Warning: Danger! Key can't be restored!
//    internal func removeKey(
//        _ key: GTTONKey
//    ) async throws {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
//            self.ton.delete(
//                key,
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Removes all keys
    ///
    /// - Throws: TODO
    /// - Warning: Danger! Keys can't be restored!
//    internal func removeAllKeys() async throws {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
//            self.ton.deleteAllKeys(
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    // MARK: - Security

    /// Returns decrypted key for given `key` and it's `userPassword`
    ///
    /// - Parameter key: An public `Key`
    /// - Parameter userPassword: An password of  given `key`
    ///
    /// - Throws: TODO
    /// - Returns: Decrypted secret key`
//    internal func decryptedSecretKeyForKey(
//        _ key: GTTONKey,
//        userPassword: Data
//    ) async throws -> Data {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.exportDecryptedKey(
//                withEncryptedKey: key,
//                withUserPassword: userPassword,
//                completionBlock: { decryptedSecretKey, error in
//                    if let decryptedSecretKey = decryptedSecretKey {
//                        continuation.resume(returning: decryptedSecretKey)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Returns word list for given key `key` and it's `userPassword`
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    ///
    /// - Throws: TODO
    /// - Returns: Words list
//    internal func wordsForKey(
//        _ key: GTTONKey,
//        userPassword: Data
//    ) async throws -> [String] {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.exportWords(
//                for: key,
//                withUserPassword: userPassword,
//                completionBlock: { words, error in
//                    if let words = words {
//                        continuation.resume(returning: words)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Returns unencrypted messages if available
    ///
    /// - Parameter key: An key of wallet
    /// - Parameter userPassword: An password of  given `key`
    /// - Parameter messages: An encrypted messages
    ///
    /// - Throws: TODO
    /// - Returns: Words list
//    internal func decryptMessagesWithKey(
//        _ key: GTTONKey,
//        userPassword: Data,
//        messages: [GTEncryptedData]
//    ) async throws -> [GTTransactionMessageContents] {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.decryptMessages(
//                with: key,
//                userPassword: userPassword,
//                messages: messages,
//                completionBlock: { contents, error in
//                    if let contents = contents {
//                        continuation.resume(returning: contents)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Returns current account address depended on `data` and `code`
    ///
    /// - Parameter data: An storage of smart contract
    /// - Parameter code: An code of smart contract
    ///
    /// - Throws: TODO
    /// - Returns: Wallet address string value
//    internal func accountAddress(
//        code: Data,
//        data: Data,
//        workchain: Int32
//    ) async throws -> String {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.accountAddress(
//                withCode: code,
//                data: data,
//                workchain: workchain,
//                completionBlock: { address, error in
//                    if let address = address {
//                        continuation.resume(returning: address)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }

    /// Returns raw account for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    /// - Throws: TODO
    /// - Returns: Current state `AccountState` of given address
//    internal func accountWithAddress(
//        _ accountAddress: String
//    ) async throws -> GTAccountState {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.accountState(
//                withAddress: accountAddress,
//                completionBlock: { account, error in
//                    if let account = account {
//                        continuation.resume(returning: account)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Returns account (smart contract) local id for given address
    ///
    /// - Parameter accountAddress: An account address
    ///
    /// - Throws: TODO
    /// - Returns: local id of account (smart contract)
//    internal func accountLocalIDWithAccountAddress(
//        _ accountAddress: String
//    ) async throws -> Int64 {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.accountLocalID(
//                withAccountAddress: accountAddress,
//                completionBlock: { id, error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: id)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Runs method on account (smart contract) with given method name
    ///
    /// - Parameter localID: local id of account (smart contract)
    ///
    /// - Throws: TODO
    /// - Returns: result of execution
//    internal func accountLocalID(
//        _ localID: Int64,
//        runGetMethodNamed methodName: String,
//        arguments: [GTExecutionStackValue]
//    ) async throws -> GTExecutionResult {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.accountLocalID(
//                localID,
//                runGetMethodNamed: methodName,
//                arguments: arguments,
//                completionBlock: { result, error in
//                    if let result = result {
//                        continuation.resume(returning: result)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    // MARK: Queries
    
    /// Prepare raw query
    ///
    /// - Parameter address: key of account
    /// - Parameter initialStateCode:
    /// - Parameter initialStateData:
    /// - Parameter body:
    ///
    /// - Throws: TODO
    /// - Returns: prepared query
//    internal func prepareQueryWithDestinationAddress(
//        _ address: String,
//        initialStateCode: Data?,
//        initialStateData: Data?,
//        body: Data
//    ) async throws -> GTPreparedQuery {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.prepareQuery(
//                withDestinationAddress: address,
//                initialAccountStateData: initialStateData,
//                initialAccountStateCode: initialStateCode,
//                body: body,
//                completionBlock: { query, error in
//                    if let query = query {
//                        continuation.resume(returning: query)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Estimate fees for query
    ///
    /// - Parameter preparedQuery: query that shoud be estimated
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
//    internal func estimateFees(
//        preparedQueryID: Int64
//    ) async throws -> GTFeesQuery {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.estimateFeesForPreparedQuery(
//                withID: preparedQueryID,
//                completionBlock: { fees, error in
//                    if let fees = fees {
//                        continuation.resume(returning: fees)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Send prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be sent
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
//    internal func send(
//        preparedQueryID: Int64
//    ) async throws {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
//            self.ton.sendPreparedQuery(
//                withID: preparedQueryID,
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    /// Remove local copy of prepared query
    ///
    /// - Parameter preparedQuery: query that shoud be removed
    ///
    /// - Throws: TODO
//    internal func remove(
//        preparedQueryID: Int64
//    ) async throws {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { (continuation: CheckedContinuation<(), Error>) in
//            self.ton.deletePreparedQuery(
//                withID: preparedQueryID,
//                completionBlock: { error in
//                    if let error = error {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    } else {
//                        continuation.resume(returning: ())
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    // MARK: DNS
    
    internal enum DNSResolverCategory: String {
        
        case next = "dns_next_resolver"
        case wallet = "wallet"
        case site = "site"
    }
    
    /// Resolve `.ton` to address
    ///
    /// - parameter rootDNSAccountAddress: address of root DNS contract account
    /// - parameter name: domain nam e.g. `durov.ton`
    ///
    /// - throws: TODO
    /// - returns: fees for query
//    internal func resolvedDNSWithRootDNSAccountAddress(
//        _ rootDNSAccountAddress: String?,
//        name: String,
//        category: DNSResolverCategory,
//        ttl: Int32
//    ) async throws -> GTDNS {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.resolvedDNS(
//                withRootDNSAccountAddress: rootDNSAccountAddress,
//                domainName: name,
//                category: category.rawValue,
//                ttl: ttl,
//                completionBlock: { dns, error in
//                    if let dns = dns {
//                        continuation.resume(returning: dns)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
    
    // MARK: Transactions
    
    /// Get transactions for account address
    ///
    /// - Parameter accountAddress: address of account
    ///
    /// - Throws: TODO
    /// - Returns: fees for query
//    internal func transactionsForAccountAddress(
//        _ accountAddress: String,
//        lastTransactionID: GTTransactionID
//    ) async throws -> [GTTransaction] {
//        let id = ton.generateRequestID()
//        return try await request(id: id, { continuation in
//            self.ton.transactions(
//                forAccountAddress: accountAddress,
//                last: lastTransactionID,
//                completionBlock: { transactions, error in
//                    if let transactions = transactions {
//                        continuation.resume(returning: transactions)
//                    } else {
//                        continuation.resume(throwingSwiftyTONError: error)
//                    }
//                },
//                requestID: id
//            )
//        })
//    }
}
