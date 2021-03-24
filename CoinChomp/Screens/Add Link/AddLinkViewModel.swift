//
//  AddLinkViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/16/21.
//

import Foundation
import UIKit


class AddLinkViewModel : ObservableObject {
    
    @Published var destination : String = ""
    @Published var auth = AuthService.shared
    
    init(){
        
        if PreferencesService.shared.autoPasteEnabled() {
            NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [unowned self] notification in
                self.getClipboardString()
            }
        }
        
    }
    
    func getClipboardString(){
        guard self.destination.count == 0 else { return }
        let pb: UIPasteboard = UIPasteboard.general
        if let string = pb.string,
           let urlString = string.getURL(),
           urlString != self.destination {
            self.destination = urlString
            self.objectWillChange.send()
        }
    }
    
    func createLink() -> Link? {
        var data : [String:Any] = [:]
        data["type"] = "web"
        data["reviewState"] = "unreviewed"
        data["sourceID"] = ""
        data["collectionMethod"] = "r"
        data["title"] = ""
        data["isHeadline"] = false
        data["destination"] = self.destination
        data["content"] = ""
        data["imageURL"] = ""
        data["userID"] = ""
        data["userName"] = ""
        data["userPhotoURL"] = ""
        data["chomp"] = 0.0
        data["weight"] = 0.0
        if let link = Link(withID: "000", fields: data) {
            return link
        }
        return nil
    }
}
