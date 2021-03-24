//
//  Message.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/23/21.
//

import Foundation

class Message : Identifiable {
    var id = UUID()
    var databaseRecordID : String?
    var userID : String
    var from: String
    var subject : String
    var body : String
    var chomp: Double
    var didOpen : Bool
    var createdAt = Date()
    
    init?(documentID: String, withFields fields: [String:Any]){
        guard let userID = fields["userID"] as? String,
           let from = fields["from"] as? String,
           let subject = fields["subject"] as? String,
           let body = fields["body"] as? String,
           let chomp = fields["chomp"] as? Double,
           let didOpen = fields["didOpen"] as? Bool else { return nil }
        self.databaseRecordID = documentID
        self.userID = userID
        self.from = from
        self.subject = subject
        self.body = body
        self.chomp = chomp
        self.didOpen = didOpen
    }
    
    func dateString() -> String {
        if let hours = createdAt.hoursElapsed() {
            if hours <= 24 {
                return createdAt.timeAgoDisplay()
            }
        }
        return createdAt.standardFormat()
    }
}
