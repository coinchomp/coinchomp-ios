//
//  ManageSubscriptionView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/15/21.
//

import SwiftUI
import StoreKit

struct ManageSubscriptionView: View {
    
    @StateObject var storeManager = StoreManager.shared
    @StateObject var viewModel = ManageSubscriptionViewModel()
    
    let user : User
    let currentSub : SubscriptionTemplate
    let upgradeSub : SubscriptionTemplate?
    let downgradeSub : SubscriptionTemplate?
    
    @State var shouldShowReceipts = false

    init?(user: User){
        guard let currentSubID = user.subscriptionProductID,
              let currentSub = SubscriptionService.shared.template(forProductID: currentSubID) else {
            return nil }
        self.user = user
        self.currentSub = currentSub
        if(self.user.isPaid == false){
            return nil
        }
        if let upgradeSub = SubscriptionService.shared.template(forProductID: currentSub.upgradeProductID) {
            self.upgradeSub = upgradeSub
        }else{ self.upgradeSub = nil }
        if let downgradeSub = SubscriptionService.shared.template(forProductID: currentSub.downgradeProductID) {
            self.downgradeSub = downgradeSub
        }else{ self.downgradeSub = nil }
    }
    
    var navReceipts: NavigationLink<EmptyView, ReceiptsView>? {
        return NavigationLink(destination: ReceiptsView(user: user),
                                  isActive: $shouldShowReceipts,
                                  label: {
                                    EmptyView()
                                  })
    }
    
    var body: some View {
                
        ZStack {
            
            navReceipts
            
            VStack(alignment: HorizontalAlignment.center, spacing: 12) {
                
                HStack {
                    Text("Type: ")
                    Spacer()
                    Text("\(currentSub.name)")
                        .foregroundColor(Color("BWForeground"))

                    if user.didCancelSubscription {
                        Text("(Cancelled)")
                            .foregroundColor(Color("BWForeground"))
                    }
                }
                
                HStack {
                    Text("Billing frequency: ")
                    Spacer()
                    Text("\(currentSub.getFrequencySummary())")
                        .foregroundColor(Color("BWForeground"))
                }
                
                HStack {
                    if user.didCancelSubscription {
                        Text("Expires on:")
                        Spacer()
                        Text(user.subscriptionExpiresAt.standardFormat())
                            .foregroundColor(Color("BWForeground"))
                    } else {
                        Text("Next billed on:")
                        Spacer()
                        Text(user.subscriptionExpiresAt.standardFormat())
                            .foregroundColor(Color("BWForeground"))
                    }
                }
                
                if user.didCancelSubscription == false {

                    if let productID = user.subscriptionProductID,
                       let product = storeManager.getProductByID(productID) {
                        HStack {
                            Text("Billing amount:")
                                .foregroundColor(Color("BWForeground"))
                            Spacer()
                            Text("\(product.localizedPrice)")
                                .foregroundColor(Color("BWForeground"))
                        }
                        .background(Color.clear)
                    }
                }
                
                Divider()
                                            
                if user.subscriptionPaymentProcessor == "apple" {
                    if user.didCancelSubscription {
                        VStack {
                            Text("You cancelled this subscription")
                                .font(.system(size: 17))
                                .foregroundColor(Color("BWForeground"))

                            Text("You'll still enjoy \(currentSub.name) features for the remainder of the subscription period.")
                                .font(.system(size: 14))
                                .foregroundColor(Color("BWForeground").opacity(0.3))
                        }
                        .padding(30)
                                                    
                    } else {
                        
                        HStack {
                            
                            RoundRectButton(text: "Receipts", foregroundColor: Color.black.opacity(0.40),
                                            backgroundColor: Color.black.opacity(0.05),
                                            iconName: "scroll", fontSize: 13, padding: 8, tapHandler: {
                                shouldShowReceipts = true
                            })
                            
                            RoundRectButton(text: "Cancel Subscription", foregroundColor: Color.black.opacity(0.40),
                                            backgroundColor: Color.black.opacity(0.05),
                                            iconName: "trash", fontSize: 13, padding: 8, tapHandler: {
                                UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
                            })
                            
                        }
                        
                        if let upgradeSub = self.upgradeSub,
                           let upgradeProduct = storeManager.getProductByID(upgradeSub.productID){
                            
                            VStack {
                                HStack {
                                    Spacer()
                                        RoundRectButton(text: viewModel.isUpgrading ? "Upgrading..." : "Upgrade to \(upgradeSub.name) for \(upgradeProduct.localizedPrice)/\(upgradeSub.getShortFrequency())", foregroundColor: Color.blue.opacity(viewModel.isUpgrading ? 0.5 : 0.90),
                                                        backgroundColor: Color.blue.opacity(viewModel.isUpgrading ? 0.05 : 0.15),
                                                                iconName: nil, fontSize: 15, tapHandler: {
                                            viewModel.isUpgrading = true
                                            storeManager.purchaseSubscription(subscription: upgradeSub, forUser: user)
                                }).disabled(viewModel.isUpgrading)
                                    Spacer()
                                }
                                
                                Text(upgradeSub.getFeatureSummary())
                                    .font(.system(size:12))
                                    .foregroundColor(Color("BWForeground").opacity(0.6))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        if let downgradeSub = self.downgradeSub,
                           let downgradeProduct = storeManager.getProductByID(downgradeSub.productID){
                            
                            VStack {
                                
                                HStack {

                                    Spacer()
                                   
                                        RoundRectButton(text: viewModel.isDowngrading ? "Downgrading..." : "Downgrade to \(downgradeSub.name) for \(downgradeProduct.localizedPrice)/\(downgradeSub.getShortFrequency())", foregroundColor: Color.orange.opacity(viewModel.isDowngrading ? 0.5 : 0.90),
                                                        backgroundColor: Color.orange.opacity(viewModel.isDowngrading ? 0.05 : 0.15),
                                                        iconName: nil, fontSize: 15, tapHandler: {
                                            viewModel.isDowngrading = true
                                            storeManager.purchaseSubscription(subscription: downgradeSub, forUser: user)
                                        }).disabled(viewModel.isDowngrading)
                                    
                                    Spacer()
                                }
                                
                                Text(downgradeSub.getFeatureSummary())
                                    .font(.system(size:12))
                                    .foregroundColor(Color("BWForeground").opacity(0.6))
                                    .lineSpacing(5)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                    }
                    
                } else {
                    VStack {
                        Text("You purchased \(currentSub.name) with \(user.subscriptionPaymentProcessor)")
                            .font(.system(size: 17))
                            .foregroundColor(Color("BWForeground"))
                        Text("Please proceed with cancellation on the platform on which you made the purchase.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("BWForeground").opacity(0.3))
                    }
                    .padding(30)
                    
                }
                    
                Spacer()
                    
            } // end VStack
            .padding(15)
                
        } // end ZStack
        .onAppear(perform: {
            // setting properties to 'install' stateobjects onto view
            storeManager.user = self.user
            viewModel.user = self.user
        })
        .padding(0)
        .navigationBarTitle("Subscription")
        .navigationBarTitleDisplayMode(.inline)
    }
}
