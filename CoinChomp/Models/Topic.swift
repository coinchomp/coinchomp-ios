//
//  Topic.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/14/21.
//

import Foundation

class Topic {
        
    let topicID : String
    let name : String
    var weight : Double = 0.0
    var links : [Link] = []
    
    init(topicID: String){
        self.topicID = topicID
        self.name = ""
    }
    
    init?(topicID: String, fields: [String:Any]){
        guard let name = fields["name"] as? String else { return nil }
        self.topicID = topicID
        self.name = name
    }
    
    func addLink(link: Link){
        self.links.append(link)
        computeWeight()
    }
    
    func computeWeight(){
        guard links.count > 0 else { return }
        if links.count == 1, let link = links.first {
            weight = link.weight
        }
        var totalWeight = 0.0
        for link in self.links {
            totalWeight+=link.weight
        }
        self.weight = totalWeight / Double(self.links.count)
    }
}
