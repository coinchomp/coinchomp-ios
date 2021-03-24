//
//  MenuViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/27/20.
//

import Foundation
import UIKit

class MenuViewModel : ObservableObject {
    
    @Published var imageLoader : ImageLoader? = nil
    @Published var user : User?
    @Published var fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
    @Published var fontSizeForBody = PreferencesService.shared.fontSizeForBody()
    @Published var fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
    func refreshFontSizes() {
        fontSizeForHeading = PreferencesService.shared.fontSizeForHeading()
        fontSizeForBody = PreferencesService.shared.fontSizeForBody()
        fontSizeForCaption = PreferencesService.shared.fontSizeForCaption()
    }
    
    @Published var auth = AuthService.shared
    @Published var versionInfo : String
    @Published var envContext : String = "?"
    @Published var showLogInView = false
    
    @Published var showProfile = false
    @Published var showMessages = false
    @Published var showStatsGuide = false
    @Published var showReview = false
    @Published var showPreferences = false
    @Published var showAddLink = false
    @Published var showTopics = false

    init(){
        if let appVersion = UIApplication.appVersion,
           let appBuildNumber = UIApplication.appBuildNumber {
            self.versionInfo = "v\(appVersion)(\(appBuildNumber))"
        } else {
            self.versionInfo = ""
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondAuthStateChange),
                       name: Notification.Name("authStateDidChange"),
                       object: nil)
    }
    
    func setUser(){
        if let user = auth.currentUser {
            self.user = user
            self.imageLoader = ImageLoader(urlString:user.photoURL)
        }
    }
    
    func refreshEnvContext() {
        self.envContext = EnvService.shared.getContextString()
    }
    
    @objc private func respondAuthStateChange(){
        if let user = auth.currentUser {
            self.user = user
            self.imageLoader = ImageLoader(urlString:user.photoURL)
            self.showLogInView = false
            self.objectWillChange.send()
        } else {
            self.user = nil
            self.imageLoader = nil
        }
    }
}
