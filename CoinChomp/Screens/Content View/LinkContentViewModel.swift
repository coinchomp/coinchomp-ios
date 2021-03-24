//
//  LinkSummaryViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/23/21.
//

import Foundation

class LinkContentViewModel : ObservableObject {
    
    @Published var selectedUser : User? = nil
    @Published var selectedVoteType : UserVoteType? = nil
    @Published var isBusy : Bool = true
    @Published var canTweet : Bool = true
    @Published var doesTweet : Bool = true
    @Published var isComposingTweet = false
    @Published var postedTweet = false

    @Published var fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
    @Published var fontSizeForBody = PreferencesService.shared.fontSizeForBody()
    @Published var fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
    
    func refreshFontSizes() {
        fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
        fontSizeForBody = PreferencesService.shared.fontSizeForBody()
        fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
    }

    let auth = AuthService.shared
    var link : Link? = nil
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondPostedTweet),
                       name: Notification.Name("postedTweet"),
                       object: nil)
    }
    
    @objc private func respondPostedTweet(){
        DispatchQueue.main.async {
            self.postedTweet = true
            self.isComposingTweet = false
        }
    }
    
    func setLink(_ link: Link){
        self.link = link
        guard let currentUser = auth.currentUser else { return }
        self.isBusy = true
        UserService.shared.fetchUserVote(userID: currentUser.userID,
                                         entityID: link.linkID){
            [weak self] (voteType, error) in
            self?.isBusy = false
            if let error = error {
                print(error.localizedDescription)
            } else if let voteType = voteType {
                self?.selectedVoteType = voteType
            } else {
                self?.selectedVoteType = nil
            }
        }
    }
    
    func recordImpression(){
        guard let link = self.link else { return }
        guard let user = auth.currentUser else { return }
        var data : [String:String] = [:]
        data["userID"] = user.userID
        data["linkID"] = link.linkID
        data["type"] = "content"
        DatabaseService.shared.recordImpression(data: data)
    }
    
    func recordVoteUp(){
        guard selectedVoteType != .Up else {
            undoVote()
            return
        }
        guard let user = auth.currentUser,
              let link = link else { return }
        isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["voteType"] = "up"
        data["entityType"] = "link"
        data["entityID"] = link.linkID
        DatabaseService.shared.recordVote(data: data){ [weak self] succeeded in
            self?.isBusy = false
            if succeeded {
                self?.selectedVoteType = UserVoteType.Up
            }
        }
    }
    
    func recordVoteDown(){
        guard selectedVoteType != .Down else {
            undoVote()
            return
        }
        guard let user = auth.currentUser,
              let link = link else { return }
        isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["voteType"] = "down"
        data["entityType"] = "link"
        data["entityID"] = link.linkID
        DatabaseService.shared.recordVote(data: data){ [weak self] succeeded in
            self?.isBusy = false
            if succeeded {
                self?.selectedVoteType = UserVoteType.Down
            }
        }
    }
    
    func undoVote(){
        guard let user = auth.currentUser,
              let link = link,
              let voteType = selectedVoteType else { return }
        isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["voteType"] = voteType.rawValue
        data["entityType"] = "link"
        data["entityID"] = link.linkID
        DatabaseService.shared.recordVote(data: data){ [weak self] succeeded in
            self?.isBusy = false
            if succeeded {
                self?.selectedVoteType = nil
            }
        }
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
}
