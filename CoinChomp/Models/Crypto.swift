//
//  Crypto.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import Foundation

let numeralMap : [String : Int] = [
    "0" : 0,
    "1" : 1,
    "2" : 2,
    "3" : 3,
    "4" : 4,
    "5" : 5,
    "6" : 6,
    "7" : 7,
    "8" : 8,
    "9" : 9,
]

class UsedCrypto {
    let cryptoID : String
    init(cryptoID: String){
        self.cryptoID = cryptoID
    }
}

class Crypto : Identifiable {
    let id = UUID()
    let databaseRecordID : String?
    let name : String
    let symbol : String
    let volume24h : Double
    let marketCap : Double
    let lastQuoteUSD : String
    let lastQuoteAt : Date
    var logoURL : String
    var slug : String
    var isEnabled : Bool = true
    var onRadar : Bool = false
    var onRadarHidden : Bool = true
    
    init(databaseRecordID: String,
         name: String,
         symbol: String,
         slug: String,
         logoURL: String,
         volume24h: Double,
         marketCap: Double,
         lastQuoteUSD: String,
         lastQuoteAt: Date){
        self.databaseRecordID = databaseRecordID
        self.name = name
        self.symbol = symbol
        self.slug = slug
        self.logoURL = logoURL
        self.volume24h = volume24h
        self.marketCap = marketCap
        self.lastQuoteUSD = lastQuoteUSD
        self.lastQuoteAt = lastQuoteAt
    }
    
    public func getPriceIncrement() -> Double {
        var exponent = log10(lastQuoteUSDDouble() / 100)
        exponent = floor(exponent)
        return pow(10, exponent)
    }
    
    public func lastQuoteUSDDouble() -> Double {
        if let double = Double(lastQuoteUSD) {
            return double
        }
        return 0.00
    }
    
    public func lastQuoteUSDDecimal() -> Decimal {
        let total : Double = lastQuoteUSDDouble()
        return NSDecimalNumber(value: total).decimalValue
    }

    static func decimalPoints(forNumberString numberString: String) -> Int {
        
        let components = numberString.components(separatedBy: ".")
        
        // Look at digits before decimal point
        if components.indices.contains(0) {
            let string = components[0]
            for character in string {
                if character != "0" {
                    return 2
                }
            }
        }
        /* If there were only zeroes before the decimal point...
         examine digits after decimal point */
        if components.indices.contains(1) {
            let string = components[1]
            var didEncounterNonZero = false
            var digitsCounted = 0
            var numberOfDigits = 1
            for character in string {
                if character != "0" {
                    didEncounterNonZero = true
                }
                if didEncounterNonZero == true {
                    digitsCounted+=1
                }
                if digitsCounted >= 4 {
                    break
                }
                numberOfDigits+=1
            }
            return numberOfDigits
        }
        return 2
    }
    
    public func priceFormatSpecifier() -> String {
        let decimalPoints = Crypto.decimalPoints(forNumberString: lastQuoteUSD)
        return "%.\(decimalPoints)f"
    }
    
    // MARK: Private methods
    
    private func returnSmallIncrementIfPossible() -> Double? {
        let quote = lastQuoteUSDDouble()
        if quote < 1.00 {
            return 0.01
        } else if quote < 10.00 {
            return 0.10
        } else if quote < 100.00 {
            return 1.00
        } else if quote < 1000.00 {
            return 10.00
        }
        return nil
    }
    
    private func roundToNearestIncrement(start : Double, increment : Double) -> Double {
        return increment * round(start / increment)
    }
    
}
