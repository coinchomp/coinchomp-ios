//
//  EditLinkViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/12/21.
//

import Foundation
import UIKit

class EditLinkViewModel : ObservableObject {
    
    @Published var imageLoader : ImageLoader = ImageLoader(urlString:"")
    
    let auth = AuthService.shared
    let db = DatabaseService.shared

    @Published var frontPageViewModel : FrontPageViewModel? = nil
    @Published var link : Link?
    @Published var curatorImageLoader : ImageLoader? = ImageLoader(urlString:"")
    @Published var errorMessage : String = ""
    @Published var isBusy : Bool = false
    @Published var showSelectTopicView : Bool = false
    @Published var chompHint : String = ""
    @Published var chompString : String = "" {
        didSet {
            guard let chompInt = Int(chompString) else { return }
            chompHint = setChompHint(withChomp: chompInt)
        }
    }
    
    @Published var isHeadline : Bool = false {
        didSet {
            link?.isHeadline = isHeadline
        }
    }
    @Published var curator : User?
    
    func prepareToShowUser(completion: @escaping (Bool)->()){
        guard let link = link,
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
                    strongSelf.curator = user
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    private func setChompHint(withChomp chomp : Int) -> String {
        if chomp <= 300 {
            return "Link will be boosted for \(chomp.description) seconds"
        } else if chomp <= 3600 {
            return "Link will be boosted for \((chomp/60).description) minutes"
        } else if chomp <= 86400 {
            return "Link will be boosted for \((chomp/3600).description) hours"
        }
        return "Link will be boosted for \((chomp/86400).description) days"
    }
    
    func saveLink(){
        self.errorMessage = ""
        guard let link = self.link else {
            self.errorMessage = "Link was not set correctly"
            return
        }
        guard let user = auth.currentUser else {
            self.errorMessage = "You need to be logged in to curate Links!"
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
        data["title"] = link.title
        data["topicID"] = link.topicID
        data["imageURL"] = link.imageURL
        data["content"] = link.content
        if let chompInt = Int(chompString) {
            data["chomp"] = chompInt
        }else{
            data["chomp"] = 0
        }
        data["isHeadline"] = isHeadline
        db.updateLink(data: data){ [weak self] (didSucceed) in
            if didSucceed == true {
                if let chompStr = self?.chompString,
                   let chompDouble = Double(chompStr),
                   let link = self?.link {
                    link.chomp = chompDouble
                }
                if self?.isHeadline == true {
                    self?.frontPageViewModel?.setHeadline(link: link)
                }
                self?.errorMessage = ""
                self?.frontPageViewModel?.isEditingLink = false
            } else {
                self?.errorMessage = "Encountered an problem. Please try again later."
            }
            self?.isBusy = false
        }
    }
    
    func pasteLinkImageURL(){
        let pb: UIPasteboard = UIPasteboard.general
        if let string = pb.string,
           let urlString = string.getURL() {
            self.link?.imageURL = urlString
            imageLoader = ImageLoader(urlString:urlString)
            self.objectWillChange.send()
        }
    }
    
    func clearLinkImageURL(){
        self.link?.imageURL = ""
        self.objectWillChange.send()
    }
    
}
