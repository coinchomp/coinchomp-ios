//
//  CompareSubscriptionsViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 2/9/21.
//

import Foundation
import StoreKit

struct SubscriptionCellData : Identifiable {
    let id = UUID()
    let product : SKProduct
    let template : SubscriptionTemplate
}

class CompareSubscriptionsViewModel : ObservableObject {
    
    @Published var cellData : [SubscriptionCellData] = []
    @Published var isUpgrading = false
    @Published var isDowngrading = false
    @Published var purchasingProductID : String?
    @Published var shouldShowManageSubscription = false

    
    var user : User?
    
    init(){
        for (productID, product) in StoreManager.shared.myProducts {
            if let template = SubscriptionService.shared.template(forProductID:productID){
                let cd = SubscriptionCellData(product: product, template: template)
                cellData.append(cd)
                let sorted = cellData.sorted { (cd1, cd2) -> Bool in
                    return cd1.template.sortOrder < cd2.template.sortOrder
                }
                cellData = sorted
            }
        }
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondPurchaseFailed),
                       name: Notification.Name("purchaseFailed"),
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(respondPurchaseSucceeded),
                       name: Notification.Name("purchaseSucceeded"),
                       object: nil)
    }
    
    @objc private func respondPurchaseFailed(){
        DispatchQueue.main.async {
            self.purchasingProductID = nil
        }
    }
    
    @objc private func respondPurchaseSucceeded(){
        DispatchQueue.main.async {
            self.shouldShowManageSubscription = true
            self.purchasingProductID = nil
        }
    }
    
    func purchase(subscription: SubscriptionTemplate){
        if let user = self.user {
            self.purchasingProductID = subscription.productID
            StoreManager.shared.purchaseSubscription(subscription: subscription, forUser: user)
        }
    }
}
