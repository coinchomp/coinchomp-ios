//
//  EditLinkViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/12/21.
//

import Foundation
import UIKit
import SwiftUI

class CreateLinkViewModel : ObservableObject {
    
    @Published var imageLoader : ImageLoader = ImageLoader(urlString:"")
    
    let auth = AuthService.shared
    let db = DatabaseService.shared

    @Published var link : Link?
    @Published var titlePlaceholder : String = "(Tap to enter title)"
    @Published var errorMessage : String = ""
    @Published var isBusy : Bool = false
    @Published var didCreateLink : Bool = false
    @Published var showSelectTopicView : Bool = false
    @Published var chompHint : String = ""
    @Published var submitButtonText : String = "Submit"
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
    
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondAuthStateChange),
                       name: Notification.Name("authStateDidChange"),
                       object: nil)
        
        
        if let linkTemplate = LinkService.shared.template(forType: "web"){
            submitButtonText = "Submit for \(linkTemplate.cost.formatChomp) CHOMP"
        }
    }
    
    @objc private func respondAuthStateChange(){
        self.objectWillChange.send()
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
    
    func saveLink(completion: @escaping (Bool)->()){
        guard let link = self.link else {
            self.errorMessage = "Error: no data to create"
            return
        }
        self.errorMessage = ""
        guard let user = auth.currentUser else {
            self.errorMessage = "You need to be logged in to curate Links!"
            return
        }
        guard user.isBanned == false else {
            self.errorMessage = "You are not allowed to create Links!"
            return
        }
        self.isBusy = true
        var data : [String:Any] = [:]
        data["userID"] = user.userID
        data["title"] = link.title
        data["topicID"] = link.topicID
        data["destination"] = link.destination
        data["isHeadline"] = link.isHeadline
        data["type"] = link.type.rawValue
        data["imageURL"] = link.imageURL
        data["content"] = link.content
        if let chompInt = Int(chompString) {
            data["chomp"] = chompInt
        }else{
            data["chomp"] = 0
        }
        data["isHeadline"] = isHeadline
        db.createLink(data: data){ [weak self] (didSucceed, errorMessage)  in
            if didSucceed == true {
                self?.errorMessage = ""
                self?.didCreateLink = true
                completion(true)
            } else {
                self?.errorMessage = "Encountered a problem. Please try again later."
                if let errorMessage = errorMessage {
                    self?.errorMessage = errorMessage
                }
                completion(false)
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
}
