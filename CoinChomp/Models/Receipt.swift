//
//  Receipt.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/1/21.
//

import Foundation

class Receipt : Identifiable, Hashable {
    
    var id = UUID()
    var receiptID : String
    var userID : String
    var productID: String
    var txType : String
    var txPaymentProvider: String
    var amount: String
    var description : String
    var createdAt = Date()
    init?(withID receiptID: String, fields: [String:Any]){
        guard let userID = fields["userID"] as? String,
              let productID = fields["productID"] as? String,
              let txType = fields["txType"] as? String,
              let txPaymentProvider = fields["txPaymentProvider"] as? String,
              let amount = fields["amount"] as? String,
              let description = fields["description"] as? String else { return nil }
        self.receiptID = receiptID
        self.userID = userID
        self.productID = productID
        self.txType = txType
        self.txPaymentProvider = txPaymentProvider
        self.amount = amount
        self.description = description
    }
    
    func isPaymentProviderApple() -> Bool {
        if txPaymentProvider == "apple" {
            return true
        }
        return false
    }
    
    func getDateString() -> String {
        if let hours = createdAt.hoursElapsed() {
            if hours < 24 {
                return createdAt.timeAgoDisplay()
            }
        }
        return createdAt.standardFormat()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.receiptID)
    }
    
    static func == (lhs: Receipt, rhs: Receipt) -> Bool {
        return lhs.receiptID == rhs.receiptID
    }
}
