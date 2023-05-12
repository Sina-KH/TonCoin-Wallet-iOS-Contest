//
//  EventsHelper.swift
//  WalletContext
//
//  Created by Sina on 5/12/23.
//

import UIKit

public class EventsHelper {
    private init() {}
    
    
    // balance update
    private static let BalanceUpdated = Notification.Name("BalanceUpdated")
    public static func balanceUpdated(to amount: Int64) {
        NotificationCenter.default.post(name: BalanceUpdated, object: nil, userInfo: ["balance": amount])
    }
    public static func observeBalanceUpdate(_ vc: UIViewController,
                                     with callback: Selector) {
        NotificationCenter.default.addObserver(vc,
                                               selector: callback,
                                               name: BalanceUpdated,
                                               object: nil)
    }
}
