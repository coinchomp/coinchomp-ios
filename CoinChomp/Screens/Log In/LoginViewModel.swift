//
//  LoginViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 11/27/20.
//

import Foundation
import Combine

class LoginViewModel: ObservableObject {
    
    private var subscriptions = Set<AnyCancellable>()
        
    @Published var auth = AuthService.shared
    
    @Published var isBusy = false
    
    @Published var contextMessage : String? = nil {
        didSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondAuthStateChange),
                       name: Notification.Name("authStateDidChange"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondAuthDidFail),
                       name: Notification.Name("authFailed"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondAuthDetectedNewUser),
                       name: Notification.Name("authDetectedNewUser"),
                       object: nil)
    }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            if self.auth.currentUserID != nil {
                self.isBusy = false
            }
            self.objectWillChange.send()
        }
    }
    
    @objc private func respondAuthDidFail(){
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.displayError("There was a problem logging in. Please restart the app and try again.")
        }
    }
    
    @objc private func respondAuthDetectedNewUser(){
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func displayError(_ message: String){
        if self.auth.currentUserID == nil {
            self.isBusy = false
            self.contextMessage = message
        }
    }
    
    public func logInWithTwitter() {
        self.isBusy = true
        self.objectWillChange.send()
        auth.loginWithTwitter()
    }
}
