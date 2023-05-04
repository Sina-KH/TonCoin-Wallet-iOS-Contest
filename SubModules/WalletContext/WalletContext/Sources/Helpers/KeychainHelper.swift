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
    public static func save(passcode: String) {
        KeychainHelper.save(passcode, forKey: passcodeKey)
    }
    public static func passcode() -> String? {
        KeychainHelper.load(withKey: KeychainHelper.passcodeKey)
    }
    // MARK: - Biometric
    private static let biometricKey = "biometric"
    public static func save(biometric: Bool) {
        KeychainHelper.save(biometric ? "1" : "0", forKey: biometricKey)
    }
    public static func isBiometricActivated() -> Bool {
        KeychainHelper.load(withKey: KeychainHelper.biometricKey) == "1"
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
