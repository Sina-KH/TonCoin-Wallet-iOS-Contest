//
//  UserDefaultsHelper.swift
//  WalletContext
//
//  Created by Sina on 5/10/23.
//

import Foundation

public struct UserDefaultsHelper {
    
    // MARK: - Passcode
    private static let selectedCurrencyIDKey = "selectedCurrencyIDKey"
    public static func select(currencyID: Int) {
        return UserDefaultsHelper.save(currencyID, forKey: selectedCurrencyIDKey)
    }
    public static func selectedCurrencyID() -> Int {
        let selectedID = UserDefaultsHelper.loadInt(withKey: UserDefaultsHelper.selectedCurrencyIDKey) ?? 1
        return selectedID > 0 ? selectedID : 1 // selectedID defaults to 0 in user defaults
    }
    
    // MARK: - Private base user defaults functionalities
    private static func save(_ val: Int?, forKey key: String) {
        return UserDefaults.standard.set(val, forKey: key)
    }
    
    private static func loadInt(withKey key: String) -> Int? {
        return UserDefaults.standard.integer(forKey: key)
    }
    
}
