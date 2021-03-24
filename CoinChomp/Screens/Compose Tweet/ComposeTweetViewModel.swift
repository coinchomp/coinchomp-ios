//
//  ComposeTweetViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/7/21.
//

import Foundation

class ComposeTweetViewModel : ObservableObject {
    
    @Published var imageLoader : ImageLoader = ImageLoader(urlString:"")

    @Published var tweetText : String = ""
    @Published var isBusy : Bool = false
    @Published var postedTweet : Bool = false
    
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
            self.isBusy = false
        }
    }
    
    func postTweet(withLink link : Link){
        isBusy = true
        let status : String = tweetText + " : https://coinchomp.com/c/" + link.linkID
        if let encodedStatus : String = TwitterService.encode(status){
            TwitterService.shared.tweet(status: encodedStatus)
        }
    }
}
