//
//  FeedItem.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import Foundation

enum LinkType : String {
    case News = "news"
    case Opinion = "opinion"
    case User = "user"
    case Web = "web"
    case Twitter = "twitter"
    case AppleAppStore = "appStore.apple"
}

class Link : Identifiable {
    
    var id = UUID()
    var type : LinkType
    var destination : String
    var imageURL : String
    var body : String
    var scryChange : Double
    var faceChange : Int
    var createdAt = Date()
    
    init?(withFields fields: [String : Any]){
        guard let typeString = fields["type"] as? String,
           let type = LinkType(rawValue: typeString),
           let destination = fields["destination"] as? String,
           let imageURL = fields["imageURL"] as? String,
           let body = fields["body"] as? String,
           let scryChange = fields["scryChange"] as? Double,
           let faceChange = fields["faceChange"] as? Int else { return nil }
        self.type = type
        self.destination = destination
        self.imageURL = imageURL
        self.body = body
        self.scryChange = scryChange
        self.faceChange = faceChange
    }
}
