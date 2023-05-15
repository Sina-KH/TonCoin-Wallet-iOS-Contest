//
//  Created by Anton Spivak
//

import Foundation

public final class CurrencyFormatter: NumberFormatter {
    
    private static let balance99Formatter: CurrencyFormatter = {
        let formatter = CurrencyFormatter()
        formatter.maximumFractionDigits = 9
        formatter.minimumFractionDigits = 9
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    private static let balance9_Formatter: CurrencyFormatter = {
        let formatter = CurrencyFormatter()
        formatter.maximumFractionDigits = 9
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    public enum FormatterOptions {
        
        case maximum9minimum9
        case maximum9
    }
    
    public static func decimal(
        from currency: Currency
    ) -> Decimal {
        let value = currency.value
        return NSDecimalNumber(value: value).multiplying(byPowerOf10: -9) as Decimal
    }
    
    public static func string(
        from currency: Currency,
        options: FormatterOptions
    ) -> String {
        let formatter: CurrencyFormatter
        switch options {
        case .maximum9minimum9:
            formatter = balance99Formatter
        case .maximum9:
            formatter = balance9_Formatter
        }
        
        let decimal = decimal(from: currency) as NSDecimalNumber
        return formatter.string(from: decimal) ?? ""
    }
    
    public static func currecny(
        from string: String
    ) -> Currency? {
        let replaced = string.replacingOccurrences(of: ",", with: ".")
        guard let decimal = balance99Formatter.number(from: replaced)
        else {
            return nil
        }
        
        let value = Int64(decimal.doubleValue * 1_000_000_000)
        return Currency(value: value)
    }
}
