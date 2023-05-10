//
//  RatesResponse.swift
//  UIWalletHome
//
//  Created by Sina on 5/10/23.
//

import Foundation

struct RatesResponse: Codable {

    let rates: Rates
    
    struct Rates: Codable {

        let TON: CurrencyRates

        struct CurrencyRates: Codable {
            
            let prices: CurrencyPrices
            
            struct CurrencyPrices: Codable {
                
                let TON: Double
                let USD: Double
                let EUR: Double
                let RUB: Double

            }
        }
    }
    
}
