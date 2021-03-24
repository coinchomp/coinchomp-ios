//
//  ProfileViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/17/20.
//

import Foundation
import FirebaseFunctions

class ProfileViewModel : ObservableObject {
    
    lazy var functions = Functions.functions()
        
    @Published var isBusy = false
    @Published var auth = AuthService.shared
    @Published var isPurchaseInProgress : Bool = false
    @Published var installed = false
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondPurchaseFailed),
                       name: Notification.Name("purchaseFailed"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondPurchaseSucceeded),
                       name: Notification.Name("purchaseSucceeded"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondPurchaseInProgress),
                       name: Notification.Name("purchaseInProgress"),
                       object: nil)
    }
    
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
        
    func refreshProfile(userID: String){
        isBusy = true
        functions.httpsCallable("refreshSocialProfile").call([]) {
            [weak self] (result, error) in
          if let error = error as NSError? {
            self?.isBusy = false
            self?.self.objectWillChange.send()
            print(error.localizedDescription)
          }else if let result = result,
                   let resultData = result.data as? [String : Any]{
            if let didUpdate = resultData["didUpdate"] as? Bool {
                if didUpdate {
                    print("did update!")
                    self?.isBusy = false
                    self?.objectWillChange.send()
                } else {
                    print("did not update")
                    self?.isBusy = false
                    self?.self.objectWillChange.send()
                }
            }
          }
        }
    }
    
    @objc private func respondPurchaseInProgress(){
        DispatchQueue.main.async {
            self.isPurchaseInProgress = true
            self.objectWillChange.send()
        }
    }
    
    @objc private func respondPurchaseFailed(){
        DispatchQueue.main.async {
            self.isPurchaseInProgress = false
            self.objectWillChange.send()
        }
    }
    
    @objc private func respondPurchaseSucceeded(){
        DispatchQueue.main.async {
            self.isPurchaseInProgress = false
            self.objectWillChange.send()
        }
    }
}
