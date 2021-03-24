//
//  Subscription.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/31/21.
//

import Foundation

class SubscriptionTemplate : Codable {
    var name : String
    var summary : String
    var detail : String
    var productID : String
    var upgradeProductID : String
    var downgradeProductID : String
    var frequency : String
    var features : [String]
    var dailyChompBonus : Double
    var sortOrder : Int
    var version : String
    
    enum CodingKeys: String, CodingKey {
        case name
        case summary
        case detail
        case productID
        case upgradeProductID
        case downgradeProductID
        case frequency
        case features
        case dailyChompBonus
        case sortOrder
        case version
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(summary, forKey: .summary)
        try container.encode(detail, forKey: .detail)
        try container.encode(productID, forKey: .productID)
        try container.encode(upgradeProductID, forKey: .upgradeProductID)
        try container.encode(downgradeProductID, forKey: .downgradeProductID)
        try container.encode(frequency, forKey: .frequency)
        try container.encode(features, forKey: .features)
        try container.encode(dailyChompBonus, forKey: .dailyChompBonus)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(version, forKey: .version)
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try values.decode(String.self, forKey: .name)
        self.summary = try values.decode(String.self, forKey: .summary)
        self.detail = try values.decode(String.self, forKey: .detail)
        self.productID = try values.decode(String.self, forKey: .productID)
        self.upgradeProductID = try values.decode(String.self, forKey: .upgradeProductID)
        self.downgradeProductID = try values.decode(String.self, forKey: .downgradeProductID)
        self.frequency = try values.decode(String.self, forKey: .frequency)
        self.features = try values.decode([String].self, forKey: .features)
        self.dailyChompBonus = try values.decode(Double.self, forKey: .dailyChompBonus)
        self.sortOrder = try values.decode(Int.self, forKey: .sortOrder)
        self.version = try values.decode(String.self, forKey: .version)
    }
    
    init?(withFields fields : [String : Any]){
        guard let name = fields["name"] as? String,
              let summary = fields["summary"] as? String,
              let detail = fields["detail"] as? String,
              let productID = fields["productID"] as? String,
              let upgradeProductID = fields["upgradeProductID"] as? String,
              let downgradeProductID = fields["downgradeProductID"] as? String,
              let frequency = fields["frequency"] as? String,
              let features = fields["features"] as? [String],
              let dailyChompBonus = fields["dailyChompBonus"] as? Double,
              let sortOrder = fields["sortOrder"] as? Int,
              let version = fields["version"] as? String else { return nil }
        self.name = name
        self.summary = summary
        self.detail = detail
        self.productID = productID
        self.upgradeProductID = upgradeProductID
        self.downgradeProductID = downgradeProductID
        self.frequency = frequency
        self.features = features
        self.dailyChompBonus = dailyChompBonus
        self.sortOrder = sortOrder
        self.version = version
    }
    
    func getFeatureSummary() -> String {
        var featureSummary = "Benifits of a '" + name + "' subscription:\n"
        var count = 1
        for feature in features {
            featureSummary = featureSummary + String(count) + ". " + feature + "\n"
            count+=1
        }
        return featureSummary
    }
    
    func getFrequencySummary() -> String {
        if frequency.contains("ly"){
            return frequency
        } else {
            return "every " + frequency
        }
    }
    
    func getShortFrequency() -> String {
       if frequency.contains("year") || frequency.contains("annual") {
            return "yr"
       }
        return "mo"
    }
}
