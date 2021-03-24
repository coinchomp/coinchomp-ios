//
//  ReviewLinkViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/17/21.
//

import Foundation

class ManualReviewViewModel : ObservableObject {
    
    let auth = AuthService.shared
    let db = DatabaseService.shared
    
    @Published var curatorImageLoader : ImageLoader? = ImageLoader(urlString:"")
    @Published var links : [Link] = []
    @Published var errorMessage : String = ""
    @Published var isBusy : Bool = false
    @Published var isHeadline : Bool = false
    @Published var selectedLink : Link? {
        didSet {
            if let link = selectedLink {
                isHeadline = link.isHeadline
            }
        }
    }
    @Published var selectedUser : User? = nil
    
    init(){}
    
    func prepareData(withLinks links : [Link]){
        self.links = links
        if let first = links.first {
            self.selectedLink = first
        }
    }
    
    func removeLinkFromCollection(_ linkID: String){
        guard let selectedLink = self.selectedLink else { return }
        var indexToRemove : Int? = nil
        for (index, link) in self.links.enumerated() {
            if link.linkID == linkID &&
                link.linkID == selectedLink.linkID {
                indexToRemove = index
                break
            }
        }
        if let index = indexToRemove {
            self.links.remove(at: index)
            self.curatorImageLoader = nil
            if let nextLink = self.links.first {
                self.selectedLink = nextLink
            }else{
                self.selectedLink = nil
            }
        }
    }

    func approveLink(){
        self.errorMessage = ""
        guard let link = self.selectedLink else {
            self.errorMessage = "Link was not set correctly"
            return
        }
        guard let user = auth.currentUser else {
            self.errorMessage = "You need to be logged in to add Links!"
            return
        }
        guard user.isBanned == false,
              (user.roles.contains("admin") || user.roles.contains("editor")) else  {
            self.errorMessage = "You cannot approve Links!"
            return
        }
        self.isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["linkID"] = link.linkID
        data["sourceID"] = link.sourceID
        data["title"] = link.title
        data["isHeadline"] = link.isHeadline
        data["content"] = link.content
        db.approveLink(data: data){ [weak self] (didSucceed, errorMessage) in
            if didSucceed == true {
                self?.removeLinkFromCollection(link.linkID)
            }else if let errorMessage = errorMessage {
                self?.errorMessage = errorMessage
            } else {
                self?.errorMessage = "Encountered an error trying to approve this Link. Please try again later."
            }
            self?.isBusy = false
        }
    }
    
    func rejectLink(){
        self.errorMessage = ""
        guard let link = self.selectedLink else {
            self.errorMessage = "Link was not set correctly"
            return
        }
        guard let user = auth.currentUser else {
            self.errorMessage = "You need to be logged in to add Links!"
            return
        }
        guard user.isBanned == false,
              (user.roles.contains("admin") || user.roles.contains("editor")) else  {
            self.errorMessage = "You cannot reject Links!"
            return
        }
        self.isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["linkID"] = link.linkID
        db.rejectLink(data: data){ [weak self] (didSucceed, errorMessage) in
            if didSucceed == true {
                self?.removeLinkFromCollection(link.linkID)
            }else if let errorMessage = errorMessage {
                self?.errorMessage = errorMessage
            } else {
                self?.errorMessage = "Encountered an error trying to approve this Link. Please try again later."
            }
            self?.isBusy = false
        }
    }
    
    func prepareToShowUser(completion: @escaping (Bool)->()){
        guard let link = selectedLink,
              link.hasCurator() == true else {
            completion(false)
            return
        }
        UserService.shared.profileForUser(userID: link.userID) {
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
}
