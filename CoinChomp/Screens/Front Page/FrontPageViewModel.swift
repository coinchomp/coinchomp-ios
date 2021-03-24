//
//  FeedViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 11/27/20.
//

import Foundation
import Combine
import Firebase

class FrontPageViewModel: ObservableObject {
        
  let auth = AuthService.shared

    var regularLinks : [Link] = [] // not headlines or in a topic
    var headlineLinks : [Link] = [] // headline links
    var topics : [String : Topic] = [:] // each topic has an array of links
    
    @Published var links : [Link] = []
    @Published var viewedLinkIDs : [String] = []
    @Published var selectedLink : Link? = nil
    @Published var selectedUser : User? = nil
    @Published var editorShowsChompSection : Bool = false
    
    @Published var isReportingLink : Bool = false {
        didSet {
            if isReportingLink == false {
                reportedLink = nil
            }
        }
    }
    @Published var reportedLink : Link? = nil {
        didSet {
            if reportedLink != nil {
                isReportingLink = true
            }
        }
    }
        
    @Published var isEditingLink : Bool = false {
        didSet {
            if isEditingLink == false {
                editedLink = nil
                editorShowsChompSection = false
            }
        }
    }
    @Published var editedLink : Link? = nil {
        didSet {
            if editedLink != nil {
                isEditingLink = true
            }
        }
    }
    
    @Published var isComposingTweet : Bool = false {
        didSet {
            if isComposingTweet == false {
                tweetedLink = nil
            }
        }
    }
    
    @Published var tweetedLink : Link? = nil {
        didSet {
            if tweetedLink != nil {
                isComposingTweet = true
            }
        }
    }
    
    @Published var dividersEnabled = PreferencesService.shared.frontPageDividersEnabled()
    @Published var fontSizeForLinkTitle = PreferencesService.shared.fontSizeForLinkTitle()
    @Published var fontSizeForLinkTitleHeadline = PreferencesService.shared.fontSizeForLinkTitleHeadline()

    func refreshFontSizes() {
        dividersEnabled = PreferencesService.shared.frontPageDividersEnabled()
        fontSizeForLinkTitle = PreferencesService.shared.fontSizeForLinkTitle()
        fontSizeForLinkTitleHeadline = PreferencesService.shared.fontSizeForLinkTitleHeadline()
    }

  init(){
    let nc = NotificationCenter.default
    nc.addObserver(self,
                   selector: #selector(respondAuthStateChange),
                   name: Notification.Name("authStateDidChange"),
                   object: nil)
  }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            self.fetchViewedLinkIDs()
            self.objectWillChange.send()
        }
    }
    
    func didUserAlreadyFlagLink(user: User, link: Link) -> Bool {
        if link.flags[user.userID] != nil {
            return true
        }
        return false
    }
    
    func fetchLinks(){
        LinkService.shared.fetchLinks() {
            [weak self] (links, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if let links = links {
                self?.didFetchLinks(fetchedLinks: links)
            }
        }
    }
    
    func fetchViewedLinkIDs(){
        if let user = auth.currentUser {
            LinkService.shared.fetchClickedLinkIDs(userID: user.userID) {
                [weak self] (viewedLinkIDs, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let viewedLinkIDs = viewedLinkIDs {
                    for linkID in viewedLinkIDs {
                        if self?.viewedLinkIDs.contains(linkID) == false{
                            self?.viewedLinkIDs.append(linkID)
                        }
                    }
                }
            }
        }
    }
    
    func didFetchLinks(fetchedLinks: [Link]){
        self.links.removeAll()
        self.headlineLinks.removeAll()
        self.topics.removeAll()
        self.regularLinks.removeAll()
        for fetchedLink in fetchedLinks {
            addLink(linkToAdd: fetchedLink)
        }
        layoutLinks()
    }
    
    func addLink(linkToAdd: Link){
                
        // If link is a headline...
        if linkToAdd.isHeadline {
            var canAdd = true
            for headlineLink in headlineLinks {
                if linkToAdd.linkID == headlineLink.linkID {
                    canAdd = false
                }
            }
            if canAdd {
                headlineLinks.append(linkToAdd)
                let sortedHeadlineLinks = headlineLinks.sorted { (l1, l2) -> Bool in
                    return l1.imageURL.count > l2.imageURL.count
                }
                headlineLinks = sortedHeadlineLinks
                return
            }
        }
        
        // If link is in a topic
        if linkToAdd.topicID.count > 0 {
            if let thisTopic = topics[linkToAdd.topicID] {
                var canAdd = true
                for topicLink in thisTopic.links {
                    if linkToAdd.linkID == topicLink.linkID {
                        canAdd = false
                    }
                }
                if canAdd {
                    thisTopic.addLink(link: linkToAdd)
                }
            } else {
                let thisTopic = Topic(topicID: linkToAdd.topicID)
                thisTopic.addLink(link: linkToAdd)
                topics[thisTopic.topicID] = thisTopic
            }
            return
        }
        
        // Otherwise add it to the regular links
        var canAdd = true
        for regularLink in regularLinks {
            if linkToAdd.linkID == regularLink.linkID {
                canAdd = false
            }
        }
        if canAdd {
            regularLinks.append(linkToAdd)
            let sortedRegularLinks = regularLinks.sorted { (l1, l2) -> Bool in
                return l1.weight > l2.weight
            }
            regularLinks = sortedRegularLinks
            return
        }
    }
    
    func layoutLinks(){
        
        self.links.removeAll()
        self.links.append(contentsOf: regularLinks)
        
        // Add Headlines
        var offset = 2
        if links.count <= offset {
            offset = 0
        }
        for headlineLink in headlineLinks.reversed() {
            self.links.insert(headlineLink, at: offset)
        }
        
        // Add Links in a Topic
        for topic in topics.values {
            var insertIndex = links.count
            for i in 0..<links.count {
                let link = links[i]
                if link.weight > topic.weight || link.isHeadline {
                    continue
                }
                insertIndex = i
                break
            }
            self.links.insert(contentsOf: topic.links, at: insertIndex)
        }
    }
    
    func setHeadline(link: Link){
        removeLinkFromCollection(link.linkID)
        link.isHeadline = true
        link.imagePosition = LinkImagePosition.Top
        addLink(linkToAdd: link)
        layoutLinks()
        self.objectWillChange.send()
    }
        
    func prepareToShowUser(userID: String, completion: @escaping (Bool)->()){
        if userID == auth.currentUserID,
           let me = auth.currentUser {
            self.selectedUser = me
            completion(true)
            return
        }
        UserService.shared.profileForUser(userID: userID) {
            [weak self] (user, error) in
            if let error = error {
                print(error)
                completion(false)
            } else if let user = user {
                if let strongSelf = self {
                    strongSelf.selectedUser = user
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    func hideAlreadyViewed() -> Bool {
        return PreferencesService.shared.hideAlreadyViewedLinksEnabled()
    }
    
    func recordClick(link: Link){
        guard let user = auth.currentUser else { return }
        if !viewedLinkIDs.contains(link.linkID) {
            viewedLinkIDs.append(link.linkID)
        }
        print("clicked link \(link.linkID)")
        var data : [String:String] = [:]
        data["linkID"] = link.linkID
        data["type"] = "link"
        data["userID"] = user.userID
        data["origin"] = "ios"
        DatabaseService.shared.recordClick(data: data)
    }
    
    func recordImpression(link: Link){
        var data : [String:String] = [:]
        data["linkID"] = link.linkID
        data["type"] = "link"
        if let user = auth.currentUser {
            data["userID"] = user.userID
        }
        DatabaseService.shared.recordImpression(data: data)
    }
    
    func deleteLink(link: Link){
        guard let currentUser = auth.currentUser else { return }
        guard currentUser.roles.contains("editor") else { return }
        var data : [String:String] = [:]
        data["linkID"] = link.linkID
        data["userID"] = currentUser.userID
        DatabaseService.shared.deleteLink(data: data, completion: {
            [weak self] (didSucceed) in
            if didSucceed {
                self?.removeLinkFromCollection(link.linkID)
            }
        })
    }
    
    func removeLinkFromCollection(_ linkID: String){
        
        // Remove from views collection
        var indexToRemove : Int? = nil
        for (index, link) in self.links.enumerated() {
            if link.linkID == linkID {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.links.remove(at: index)
        }
        
        // Remove from internal regular links collection
        indexToRemove = nil
        for (index, link) in self.regularLinks.enumerated() {
            if link.linkID == linkID {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.regularLinks.remove(at: index)
        }
        
        // Remove from internal headlines collection
        indexToRemove = nil
        for (index, link) in self.headlineLinks.enumerated() {
            if link.linkID == linkID {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.headlineLinks.remove(at: index)
        }
        
        // Remove from internal topics collection
        for topic in self.topics.values {
            indexToRemove = nil
            for (index, link) in topic.links.enumerated() {
                if link.linkID == linkID {
                    indexToRemove = index
                    break
                }
            }
            if let index = indexToRemove {
                topic.links.remove(at: index)
            }
        }
    }
}
    

