//
//  AuthService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 11/20/20.
//

import Foundation
import Firebase
import FirebaseAuth
import Combine
import LocalAuthentication

class AuthService {
        
    static let shared = AuthService()
    
    let dbService = DatabaseService.shared
    
    let kcService = KeychainWrapper()
    
    static let firebaseAuth = Auth.auth()
    
    let provider = OAuthProvider(providerID:"twitter.com")
    
    var currentUserID : String?
    
    var currentUser : User?
    
    var ignoreNextUpdateCallback = false
    
    var isNewUser = false
    
    var handle : AuthStateDidChangeListenerHandle?
        
    init(){ }
    
    public func startListening(){
        self.handle = Auth.auth().addStateDidChangeListener {
            [weak self] (auth, user) in
            if let user = user {
                self?.currentUserID = user.uid
                UserService.shared.listenToUser(withID: user.uid){
                    [weak self] (profile, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else if let profile = profile {
                        self?.didUpdateUser(user: profile)
                    }
                }
            } else {
                self?.logOut()
            }
        }
    }
    
    public func stopListening(){
        UserService.shared.cancelListeners()
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    private func didUpdateUser(user : User){
        self.currentUser = user
        self.currentUserID = user.userID
        if self.isNewUser == false {
            //dbService.awardDailyLoginBonus(user: user)
        }
        self.isNewUser = false
        notifyAuthStateDidChange()
    }
    
    // MARK: - Authentication methods
    // MARK: TODO: SMELLY CODE HERE!!!!
    /*
     AuthService should not depend on UserService. Use DI
     */
    public func logOut() {
        do {
            try Self.firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        stopListening()
        resetProfile()
        notifyAuthStateDidChange()
    }
    
    private func resetProfile(){
        self.currentUserID = nil
        self.currentUser = nil
        deleteTwitterCreds()
        UserService.wipeUserPreferences()
    }
    
    private func notifyAuthStateDidChange(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("authStateDidChange"), object: nil)
    }
    
    private func notifyAuthFailed(){
        if currentUserID == nil {
            logOut()
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("authFailed"), object: nil)
        }
    }
    
    private func notifyAuthDetectedNewUser(){
        if currentUserID == nil {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("authDetectedNewUser"), object: nil)
        }
    }
    
    public func twitterCredentials() -> (consumerKey: String,
                                         consumerSecret: String,
                                         accessToken: String,
                                         accessTokenSecret: String)? {
        if let ck = getSecureCredential(withKey: "twitterConsumerKey"),
           let cs = getSecureCredential(withKey: "twitterConsumerSecret"),
           let at = getSecureCredential(withKey: "twitterAccessToken"),
           let ats = getSecureCredential(withKey: "twitterAccessTokenSecret"){
            return (ck, cs, at, ats)
        }
        return nil
    }
    
    private func deleteTwitterCreds(){
        deleteSecureCredential(withKey: "twitterAccessToken")
        deleteSecureCredential(withKey: "twitterAccessTokenSecret")
    }
    
    private func storeTwitterCreds(accessToken at: String,
                                   accessTokenSecret ats: String){
        deleteTwitterCreds()
        storeSecureCredential(withKey: "twitterAccessToken", value: at)
        storeSecureCredential(withKey: "twitterAccessTokenSecret", value: ats)
    }
    
    func getSecureCredential(withKey key: String) -> String? {
        if let cred = try? kcService.getGenericPasswordFor(account: "CoinChomp",
                                                           service: key){
           return cred
        }
        return nil
    }
    
    func storeSecureCredential(withKey key: String, value: String){
        deleteSecureCredential(withKey: key)
        do {
            try kcService.storeGenericPasswordFor(account: "CoinChomp",
                                              service: key,
                                              password: value)
        } catch let error as KeychainWrapperError {
            print("Exception setting password: \(error.message ?? "no message")")
        } catch {
            print("An error occurred setting the password.")
        }
    }
    
    func deleteSecureCredential(withKey key: String){
        do {
            try kcService.deleteGenericPasswordFor(account: "CoinChomp", service: key)
        } catch let error as KeychainWrapperError {
            print("Exception deleting password: \(error.message ?? "no message")")
        } catch {
            print("An error occurred setting the password.")
        }
    }
    
    public func loginWithTwitter() {
        provider.getCredentialWith(nil) { [weak self] credential, error in
            if let error = error {
                print(error.localizedDescription)
                print(error._code)
                self?.notifyAuthFailed()
            } else if let credential = credential {
                Self.firebaseAuth.signIn(with:credential) { [weak self] authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                        self?.notifyAuthFailed()
                    } else if let authResult = authResult,
                              let credential = authResult.credential as? OAuthCredential,
                              let accessToken = credential.accessToken,
                              let secret = credential.secret,
                              let userInfo = authResult.additionalUserInfo {
                        print(credential.idToken as Any)
                        if userInfo.isNewUser {
                            self?.isNewUser = true
                            self?.notifyAuthDetectedNewUser()
                        }
                        self?.storeTwitterCreds(accessToken: accessToken,
                                          accessTokenSecret: secret)
                        self?.startListening()
                    }
                }
            }
        }
    }
}
