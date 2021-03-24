//
//  ImpressionService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/25/21.
//

import Foundation
import UIKit

enum ImpressionType : String {
    case Headline = "headline"
    case Content = "content"
}

struct Impression: Encodable {
    var linkID: String
    var count: Int
    var lastLoggedAt: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case linkID = "linkID"
        case count = "count"
    }
}

class ImpressionService {
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondEnterBackground),
                       name: UIScene.willDeactivateNotification,
                       object: nil)
    }
    
    @objc private func respondEnterBackground(){
        DispatchQueue.main.async {
            self.sendImpressions()
        }
    }
    
    var isBusy = false
    
    var impressions : [String : Impression] = [:]
    var impressionsInTransit : [String : Impression] = [:]
    
    static let shared = ImpressionService()
    
    func logHeadlineImpression(linkID: String){
        let nowTime = Date().timeIntervalSince1970
        if var impression = impressions[linkID] {
            let elapsed = nowTime - impression.lastLoggedAt
            if elapsed < 2 {
                return
            }
            impression.count+=1
            impressions[linkID] = impression
        }else{
            let impression = Impression(linkID: linkID, count: 1, lastLoggedAt: nowTime)
            impressions[linkID] = impression
        }

        var totalImpressionCount = 0
        let values = impressions.map { $0.value }
        for value in values {
            totalImpressionCount+=value.count
        }
        
        if totalImpressionCount > 100 && isBusy == false {
            sendImpressions()
        }
    }
    
    func sendImpressions(){
        isBusy = true
        for (k, v) in impressions {
            if var existingImpression = impressionsInTransit[k] {
                existingImpression.count+=v.count
                impressionsInTransit[k] = existingImpression
            }else{
                impressionsInTransit[k] = v
            }
        }
        impressions.removeAll()
        var data : [String:Any] = [:]
        let values = impressionsInTransit.map { (key, value) -> [String:Any] in
            ["linkID" : value.linkID, "count": value.count ]
        }
        //print("sending \(values.count) impressions....")
        data["impressions"] = values
        if let user = AuthService.shared.currentUser {
            data["userID"] = user.userID
        }
        self.impressions.removeAll()
        DatabaseService.shared.bulkRecordHeadlineImpressions(data: data){
            [weak self] didSucceed in
            if didSucceed {
                self?.impressionsInTransit.removeAll()
            }
            self?.isBusy = false
        }
    }
}
