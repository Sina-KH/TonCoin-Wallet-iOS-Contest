//
//  StringUtils.swift
//  WalletContext
//
//  Created by Sina on 5/13/23.
//

import Foundation

public extension String {
    func normalizeArabicPersianNumeralStringToWestern() -> String {
        var string = self

        let numerals = [
            ("0", "٠", "۰"),
            ("1", "١", "۱"),
            ("2", "٢", "۲"),
            ("3", "٣", "۳"),
            ("4", "٤", "۴"),
            ("5", "٥", "۵"),
            ("6", "٦", "۶"),
            ("7", "٧", "۷"),
            ("8", "٨", "۸"),
            ("9", "٩", "۹"),
            (",", "٫", "٫")
        ]

        for (western, arabic, persian) in numerals {
                string = string.replacingOccurrences(of: arabic, with: western)
                string = string.replacingOccurrences(of: persian, with: western)
        }

        return string
    }

}
