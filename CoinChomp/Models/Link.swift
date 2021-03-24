//
//  Link.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import Foundation

enum CollectionMethod : String {
    case Scrape = "s"
    case RSS = "r"
    case UserSubmitted = "u"
}

enum ReviewState : String {
    case Unreviewed = "unreviewed"
    case Approved = "approved"
    case Rejected = "rejected"
}

enum LinkType : String {
    case User = "user"
    case Web = "web"
    case Video = "video"
    case Podcast = "podcast"
    case Twitter = "twitter"
    case AppleAppStore = "appStore.apple"
}

enum LinkImagePosition : String {
    case Top = "top"
    case Left = "left"
    case Right = "right"
}

class Link : Identifiable, Hashable {
    
    var id = UUID()
    var linkID : String
    var sourceID : String
    var collectionMethod : CollectionMethod
    var type : LinkType
    var title : String
    var isHeadline : Bool
    var destination : String
    var content : String
    var topicID : String = ""
    var imageURL : String
    var imagePosition : LinkImagePosition = .Left
    var userID : String
    var userName : String
    var userPhotoURL : String
    var weight : Double
    var chomp : Double
    var reviewState : ReviewState
    var createdAt = Date()
    
    // Moderation
    var flagID : String = ""
    var flaggedReason : String = ""
    var flaggedByUserID : String = ""
    
    var isFlagged : Bool = false
    var flags : [String:String] = [:]
    
    init?(withID linkID: String, fields: [String : Any]){
        guard let typeString = fields["type"] as? String,
           let type = LinkType(rawValue: typeString),
           let reviewStateStr = fields["reviewState"] as? String,
           let reviewState = ReviewState(rawValue: reviewStateStr),
           let sourceID = fields["sourceID"] as? String,
           let collectionMethodStr = fields["collectionMethod"] as? String,
           let collectionMethod = CollectionMethod(rawValue: collectionMethodStr),
           let title = fields["title"] as? String,
           let isHeadline = fields["isHeadline"] as? Bool,
           let destination = fields["destination"] as? String,
           let content = fields["content"] as? String,
           let imageURL = fields["imageURL"] as? String,
           let userID = fields["userID"] as? String,
           let userName = fields["userName"] as? String,
           let userPhotoURL = fields["userPhotoURL"] as? String,
           let chomp = fields["chomp"] as? Double,
           let weight = fields["weight"] as? Double else { return nil }
        
        if let topicID = fields["topicID"] as? String {
            self.topicID = topicID
        }
        if let flags = fields["flags"] as? [String:String] {
            self.flags = flags
        }
        if let isFlagged = fields["isFlagged"] as? Bool {
            self.isFlagged = isFlagged
        }
        if let imagePositionStr = fields["imagePosition"] as? String,
           let imagePosition = LinkImagePosition(rawValue: imagePositionStr) {
            self.imagePosition = imagePosition
        }

        self.linkID = linkID
        self.sourceID = sourceID
        self.collectionMethod = collectionMethod
        self.type = type
        self.title = title
        self.isHeadline = isHeadline
        self.destination = destination
        self.content = content
        self.imageURL = imageURL
        self.userID = userID
        self.userName = userName
        self.userPhotoURL = userPhotoURL
        self.reviewState = reviewState
        self.chomp = chomp
        self.weight = weight
    }
    
    func hasCurator() -> Bool {
        return (userName.count > 0) &&
            (userID.count > 0) &&
            (userPhotoURL.count > 0)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    static func == (lhs: Link, rhs: Link) -> Bool {
        return lhs.id == rhs.id
    }
}

class LinkTemplate : Codable {
    var type : String
    var cost : Double
    var input : Double
    var version : String
    
    enum CodingKeys: String, CodingKey {
        case type
        case cost
        case input
        case version
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(cost, forKey: .cost)
        try container.encode(input, forKey: .input)
        try container.encode(version, forKey: .version)
    }
    
    required init(from decoder:Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try values.decode(String.self, forKey: .type)
        self.cost = try values.decode(Double.self, forKey: .cost)
        self.input = try values.decode(Double.self, forKey: .input)
        self.version = try values.decode(String.self, forKey: .version)
    }
    
    init?(withFields fields : [String : Any]){
        guard let type = fields["type"] as? String,
              let cost = fields["cost"] as? Double,
              let input = fields["input"] as? Double,
              let version = fields["version"] as? String else { return nil }
        self.type = type
        self.cost = cost
        self.input = input
        self.version = version
    }
}
