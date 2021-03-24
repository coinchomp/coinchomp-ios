//
//  StoreManager.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/15/21.
//

import Foundation
import StoreKit

/*
 Future reference:
 Apple's IAP is hell to develop and test.
 Here are some things that are useful to know:
 1. Yes, Apple WILL send server-to-server notificatins to your url for sandbox testing
 2. Apple compresses the time of each subscription so a monthly subscription completes in like a minute, and a yearly subscription is compressed into like an hour.
 3. Add all metadata (including screenshots to in app purchases) so their status is updated away from 'missing metadata'
 
 1 month  =  5 minutes
 1 year   =  1 hour
 
 */

extension SKProduct {
    fileprivate static var formatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }

    var localizedPrice: String {
        if self.price == 0.00 {
            return "Free"
        } else {
            let formatter = SKProduct.formatter
            formatter.locale = self.priceLocale

            guard let formattedPrice = formatter.string(from: self.price) else {
                return "Unknown Price"
            }
            return formattedPrice
        }
    }
}

class StoreManager : NSObject,
                     ObservableObject,
                     SKProductsRequestDelegate,
                     SKPaymentTransactionObserver {
    
    static let shared = StoreManager()
    
    let dbService = DatabaseService.shared
        
    var user : User?
    
    var product : SKProduct?

    @Published var myProducts = [String:SKProduct]()
    
    @Published var transactionState: SKPaymentTransactionState?
        
    override init(){
        super.init()
        SKPaymentQueue.default().add(self)
        getProducts()
    }

    var request: SKProductsRequest!
    
    func productIDs() -> [String] {
        var productIDs : [String] = []
        for template in SubscriptionService.shared.templates {
            productIDs.append(template.productID)
        }
        return productIDs
    }
    
    func currentSubscription(forUser user: User) -> SubscriptionTemplate? {
        if let subbedProductID = user.subscriptionProductID,
           let currentSub = SubscriptionService.shared.template(forProductID: subbedProductID){
            return currentSub
        }
        return nil
    }
    
    func nextUpgrade(forUser user: User) -> SubscriptionTemplate? {
        if user.isPaid == false {
            if SubscriptionService.shared.templates.count > 0 {
                return SubscriptionService.shared.templates[0]
            }
        } else if let subbedProductID = user.subscriptionProductID,
                  let currentSub = SubscriptionService.shared.template(forProductID: subbedProductID){
            if let upgradeSub = SubscriptionService.shared.template(forProductID: currentSub.upgradeProductID){
                return upgradeSub
            }
        }
        return nil
    }
    
    func nextDowngrade(forUser user: User) -> SubscriptionTemplate? {
        if user.isPaid == false {
            if SubscriptionService.shared.templates.count > 0 {
                return SubscriptionService.shared.templates.first
            }
        } else if let userCurrentSubscriptionProductID = user.subscriptionProductID,
                  let currentSub = SubscriptionService.shared.template(forProductID: userCurrentSubscriptionProductID){
            if let downgradeSub = SubscriptionService.shared.template(forProductID: currentSub.downgradeProductID){
                return downgradeSub
            }
        }
        return nil
    }
    
    func purchaseSubscription(subscription: SubscriptionTemplate, forUser user: User){
        if let product = myProducts[subscription.productID] {
            if SKPaymentQueue.canMakePayments() {
                self.user = user
                self.product = product // <-- Left off Sunday night. This was nil on transaction success... when upgrading to business...
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                print("User can't make payment.")
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }

    func getProducts() {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs()))
        request.delegate = self
        request.start()
    }
    
    func getProductByID(_ productID: String) -> SKProduct? {
        if let product = myProducts[productID] {
            return product
        }
        return nil
    }
    
    private func notifyPurchaseFailed(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("purchaseFailed"), object: nil)
    }
    
    private func notifyPurchaseSucceeded(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("purchaseSucceeded"), object: nil)
    }
    
    private func notifyPurchaseInProgress(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("purchaseInProgress"), object: nil)
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                queue.finishTransaction(transaction)
                transactionState = .purchased
                if let user = self.user,
                   let txID = transaction.transactionIdentifier,
                   let txPurchaseDate = transaction.transactionDate,
                   let product = self.product {
                    var data : [String:Any] = [:]
                    // must pass the date to firebase as seconds... see: https://stackoverflow.com/questions/56420690/firestore-timestamp-passed-through-callable-functions
                    data["subscriptionOriginalTxPurchasedAt"] = txPurchaseDate.timeIntervalSince1970
                    data["subscriptionPaymentProcessor"] = "apple"
                    data["subscriptionOriginalTxID"] = txID
                    data["subscriptionProductID"] = product.productIdentifier
                    data["userID"] = user.userID
                    dbService.startSubscription(data: data){ [weak self] didSucceed in
                        if didSucceed == true {
                            self?.notifyPurchaseSucceeded()
                            print("transaction successful!")
                        }else{
                            self?.notifyPurchaseFailed()
                            print("failed transaction")
                        }
                    }
                }
            case .restored:
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed,.deferred:
                print(transaction.error!.localizedDescription)
                queue.finishTransaction(transaction)
                transactionState = .failed
                notifyPurchaseFailed()
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Store manager products request: did receive response")
        if !response.products.isEmpty {
            for p in response.products {
                DispatchQueue.main.async {
                    print("found \(p.productIdentifier)")
                    self.myProducts[p.productIdentifier] = p
                }
            }
        }
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
}
