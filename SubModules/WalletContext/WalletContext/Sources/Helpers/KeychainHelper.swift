//
//  KeychainHelper.swift
//  WalletContext
//
//  Created by Sina on 4/20/23.
//

import Foundation
import Security

public struct KeychainHelper {

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
    
    // MARK: - Ton Connect KeyPair
    private static var tonConnectKeyPairKey = "tonConnectKeyPair"
    public static func save(keyPair: String?) {
        KeychainHelper.save(keyPair, forKey: tonConnectKeyPairKey)
    }
    public static func tonConnectKeyPair() -> String? {
        KeychainHelper.load(withKey: tonConnectKeyPairKey)
    }
    
    // MARK: - Ton Connect LastEventID
    private static var tonConnectLastEventIDKey = "tonConnectLastEventID"
    public static func save(lastEventID: Int?) {
        guard let lastEventID else {
            KeychainHelper.save(nil, forKey: tonConnectLastEventIDKey)
            return
        }
        KeychainHelper.save("\(lastEventID)", forKey: tonConnectLastEventIDKey)
    }
    public static func tonConnectLastEventID() -> Int? {
        if let lastEvent = KeychainHelper.load(withKey: tonConnectLastEventIDKey) {
            return Int(lastEvent)
        }
        return nil
    }
    
    // MARK: - Ton Connect DApps
    private static var tonConnectDApps = "tonConnectDApps"
    public static func save(DApps: String?) {
        KeychainHelper.save(DApps, forKey: tonConnectDApps)
    }
    public static func dApps() -> String? {
        KeychainHelper.load(withKey: tonConnectDApps)
    }
    
    // MARK: - Delete Wallet
    public static func deleteWallet() {
        KeychainHelper.save(passcode: nil)
        KeychainHelper.save(biometric: nil)
        KeychainHelper.save(keyPair: nil)
        KeychainHelper.save(lastEventID: nil)
        KeychainHelper.save(DApps: nil)
    }

    // MARK: - Private base keychain functionalities
    private static func save(_ string: String?, forKey key: String) {
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
