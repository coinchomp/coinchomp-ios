//
//  User.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 12/4/20.
//

import Foundation

class User : Identifiable {
    var id = UUID()
    var userID : String
    var name : String
    var twitterScreenName : String
    var photoURL : String
    var chomp : Double = 0.0
    var score : Double = 0.0
    var roles : [String] = []
    var scorePercentile : Int = 0
    var createdAt = Date()
    var lastSeenAt = Date()
    var lastUpdatedSocialProfileAt = Date()
    var didLogInToday : Bool = true
    var isBanned : Bool = false
    var isPaid : Bool = false
    var didCancelSubscription : Bool = false
    var subscriptionPaymentProcessor = ""
    var subscriptionProductID : String?
    var subscriptionExpiresAt = Date()
    
    init(userID: String, fields: [String : Any?]){
        self.userID = userID
        self.name = ""
        self.twitterScreenName = ""
        self.photoURL = ""
        if let name = fields["name"] as? String {
            self.name = name
        }
        if let twitterScreenName = fields["twitterScreenName"] as? String {
            self.twitterScreenName = twitterScreenName
        }
        if let photoURL = fields["photoURL"] as? String {
            self.photoURL = photoURL
        }
        if let chomp = fields["chomp"] as? Double {
            self.chomp = chomp
        }
        if let score = fields["score"] as? Double {
            self.score = score
        }
        if let scorePercentile = fields["scorePercentile"] as? Int {
            self.scorePercentile = scorePercentile
        }
        if let didLogInToday = fields["didLogInToday"] as? Bool {
            self.didLogInToday = didLogInToday
        }
        if let isBanned = fields["banned"] as? Bool {
            self.isBanned = isBanned
        }
        if let isPaid = fields["paid"] as? Bool {
            self.isPaid = isPaid
        }
        if let roles = fields["roles"] as? [String] {
            self.roles = roles
        }
        if let didCancelSubscription = fields["subscriptionDidCancel"] as? Bool {
            self.didCancelSubscription = didCancelSubscription
        }
        if let subscriptionProductID = fields["subscriptionProductID"] as? String {
            self.subscriptionProductID = subscriptionProductID
        }
        if let subscriptionPaymentProcessor = fields["subscriptionPaymentProcessor"] as? String {
            self.subscriptionPaymentProcessor = subscriptionPaymentProcessor
        }
    }
    
    init(userID: String, name: String, photoURL: String){
        self.userID = userID
        self.name = name
        self.twitterScreenName = ""
        self.photoURL = photoURL
    }
    
    func getName() -> String {
        if twitterScreenName.count > 0 {
            return twitterScreenName
        }
        return name
    }

    func getScorePercentileSummary() -> String {
        if(scorePercentile >= 50){
            return "\(scorePercentile)th percentile"
        }
        return ""
    }
        
    func canPullDataFromSocialProfile() -> Bool {
        let now = Date()
        let diffComponents = Calendar.current.dateComponents([.hour],
                                                             from: lastUpdatedSocialProfileAt,
                                                             to: now)
        if let hours = diffComponents.hour {
            let hoursAbsolute = abs(hours)
            if hoursAbsolute >= 24 {
                return true
            }
        }
        return false
    }
}
