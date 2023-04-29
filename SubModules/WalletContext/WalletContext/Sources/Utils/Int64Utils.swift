//
//  Int64Utils.swift
//  WalletContext
//
//  Created by Sina on 4/29/23.
//

import Foundation

extension Int64 {
    
    public var dateTimeString: String {
        var t: time_t = Int(self)
        var timeinfo = tm()
        localtime_r(&t, &timeinfo);
        
        let dayString = "\(timeinfo.tm_mday)"
        let yearString = "\(2000 + timeinfo.tm_year - 100)"
        let timeString = stringForShortTimestamp(hours: Int32(timeinfo.tm_hour), minutes: Int32(timeinfo.tm_min))
        
        let monthFormat: String
        switch timeinfo.tm_mon + 1 {
        case 1:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m1.localized
        case 2:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m2.localized
        case 3:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m3.localized
        case 4:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m4.localized
        case 5:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m5.localized
        case 6:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m6.localized
        case 7:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m7.localized
        case 8:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m8.localized
        case 9:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m9.localized
        case 10:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m10.localized
        case 11:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m11.localized
        case 12:
            monthFormat = WStrings.Wallet_Time_PreciseDate_m12.localized
        default:
            return ""
        }

        return WStrings.fillValues(monthFormat, values: [dayString, yearString, timeString])
    }

}
