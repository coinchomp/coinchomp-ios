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
    
  let db = Firestore.firestore()
    
  let auth = AuthService.shared
    
  @Published var links : [Link] = []
  @Published var selectedLink : Link? = nil
  @Published var selectedUser : User? = nil

  init(){
    let nc = NotificationCenter.default
    nc.addObserver(self,
                   selector: #selector(respondAuthStateChange),
                   name: Notification.Name("authStateDidChange"),
                   object: nil)
  }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    func startListening(){
        LinkService.shared.listenForLinks {
            [weak self] (links, err) in
            if let err = err {
                print(err.localizedDescription)
            } else if let links = links {
                self?.didUpdateLinks(links: links)
            }
        }
    }
    
    func stopListening(){
        LinkService.shared.cancelListeners()
    }
    
    func didUpdateLinks(links: [Link]){
        self.links.removeAll()
        for link in links {
            self.links.append(link)
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
    
    func recordClick(link: Link){
        var data : [String:String] = [:]
        data["linkID"] = link.linkID
        data["type"] = "headline"
        if let user = auth.currentUser {
            data["userID"] = user.userID
        }
        DatabaseService.shared.recordClick(data: data)
    }
    
    func recordImpression(link: Link){
        var data : [String:String] = [:]
        data["linkID"] = link.linkID
        data["type"] = "headline"
        if let user = auth.currentUser {
            data["userID"] = user.userID
        }
        DatabaseService.shared.recordImpression(data: data)
    }
    
}
    

