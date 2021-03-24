//
//  ManageSubscriptionViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/17/21.
//

import Foundation
import SwiftUI

class ManageSubscriptionViewModel : ObservableObject {
    
    @Published var receipts : [Receipt] = []
    @Published var isUpgrading = false
    @Published var isDowngrading = false
    
    var user : User?
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondAuthStateChange),
                       name: Notification.Name("authStateDidChange"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondPurchaseFailed),
                       name: Notification.Name("purchaseFailed"),
                       object: nil)
    }
    
    @objc private func respondPurchaseFailed(){
        DispatchQueue.main.async {
            self.isUpgrading = false
            self.isDowngrading = false
        }
    }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
}
