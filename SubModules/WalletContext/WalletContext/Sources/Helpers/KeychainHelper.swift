//
//  KeychainHelper.swift
//  WalletContext
//
//  Created by Sina on 4/20/23.
//

import Foundation
import Security

public struct KeychainHelper {

    // MARK: - Wallet Version
    private static let walletVersionKey = "walletVersion"
    public static func save(walletVersion: Int?) {
        guard let walletVersion else {
            KeychainHelper.save(nil, forKey: walletVersionKey)
            return
        }
        KeychainHelper.save("\(walletVersion)", forKey: walletVersionKey)
    }
    public static func walletVersion() -> Int? {
        Int(KeychainHelper.load(withKey: KeychainHelper.walletVersionKey) ?? "")
    }
    
    // MARK: - Passcode
    private static let passcodeKey = "passcode"
    public static func save(passcode: String?) {
        KeychainHelper.save(passcode, forKey: passcodeKey)
    }
    public static func passcode() -> String? {
        KeychainHelper.load(withKey: KeychainHelper.passcodeKey)
    }
    // MARK: - Biometric
    private static let biometricKey = "biometric"
    public static func save(biometric: Bool?) {
        guard let biometric else {
            KeychainHelper.save(nil, forKey: biometricKey)
            return
        }
        KeychainHelper.save(biometric ? "1" : "0", forKey: biometricKey)
    }
    public static func isBiometricActivated() -> Bool {
        KeychainHelper.load(withKey: KeychainHelper.biometricKey) == "1"
    }
    // MARK: - AppLock
    private static let appLockKey = "appLock"
    public static func save(appLock: Bool) {
        KeychainHelper.save(appLock ? "1" : "0", forKey: appLockKey)
    }
    public static func isAppLockActivated() -> Bool {
        KeychainHelper.load(withKey: KeychainHelper.appLockKey) != "0"
    }
    // MARK: - Notifications
    private static let notificationsKey = "notifications"
    public static func save(notifications: Bool) {
        KeychainHelper.save(notifications ? "1" : "0", forKey: notificationsKey)
    }
    public static func isNotificationActivated() -> Bool {
        KeychainHelper.load(withKey: KeychainHelper.notificationsKey) != "0"
    }

    // MARK: - Ton Connect DApps
    private static var tonConnectDApps = "tonConnectDApps"
    public static func save(DApps: String?, walletVersion: Int) {
        KeychainHelper.save(DApps, forKey: "\(tonConnectDApps)_\(walletVersion)")
    }
    public static func dApps(walletVersion: Int) -> String? {
        KeychainHelper.load(withKey: "\(tonConnectDApps)_\(walletVersion)")
    }
    
    // MARK: - Recent addresses
    private static var recentAddressesKey = "recentAddresses"
    public static func save(recentAddresses: String?, walletVersion: Int) {
        KeychainHelper.save(recentAddresses, forKey: "\(recentAddressesKey)_\(walletVersion)")
    }
    public static func recentAddresses(walletVersion: Int) -> String? {
        KeychainHelper.load(withKey: "\(recentAddressesKey)_\(walletVersion)")
    }

    // MARK: - Delete Wallet
    public static func deleteWallet() {
        KeychainHelper.save(walletVersion: nil)
        KeychainHelper.save(passcode: nil)
        KeychainHelper.save(biometric: nil)
        KeychainHelper.save(appLock: true)
        for walletVersion in [31, 32, 42] {
            KeychainHelper.save(DApps: nil, walletVersion: walletVersion)
            KeychainHelper.save(recentAddresses: nil, walletVersion: walletVersion)
        }
    }

    // MARK: - Private base keychain functionalities
    private static var _cachedValues: [String: String?] = [:]
    private static func save(_ string: String?, forKey key: String) {
        // cache value to prevent sync issues with keychain
        KeychainHelper._cachedValues[key] = string

        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                _ = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
            } else {
                _ = SecItemDelete(query)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                _ = SecItemAdd(query, nil)
            }
        }
    }
    
    private static func load(withKey key: String) -> String? {
        // load from cache to prevent sync issues with keychain
        if KeychainHelper._cachedValues.keys.contains(key) {
            return KeychainHelper._cachedValues[key]! // ! to convert String?? to String?
        }

        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
            else {
                return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
    
    private static func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
    
}
