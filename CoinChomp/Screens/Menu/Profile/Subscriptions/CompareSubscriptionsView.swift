//
//  ManageSubscriptionView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/15/21.
//

import SwiftUI
import StoreKit

struct CompareSubscriptionsView: View {

    @StateObject var viewModel = CompareSubscriptionsViewModel()
    
    let user : User
    let currentSub : SubscriptionTemplate?
    let upgradeSub : SubscriptionTemplate?
    let downgradeSub : SubscriptionTemplate?
    
    var navManageSubscription: NavigationLink<EmptyView, ManageSubscriptionView>? {
        guard let view = ManageSubscriptionView(user: user) else { return nil }
        return NavigationLink(
            destination: view,
            isActive: $viewModel.shouldShowManageSubscription
        ) {
            EmptyView()
        }
    }

    init(user: User){
        if let currentSubID = user.subscriptionProductID,
           let currentSub = SubscriptionService.shared.template(forProductID: currentSubID) {
            self.currentSub = currentSub
            if let upgradeSub = SubscriptionService.shared.template(forProductID: currentSub.upgradeProductID) {
                self.upgradeSub = upgradeSub
            }else{ self.upgradeSub = nil }
            if let downgradeSub = SubscriptionService.shared.template(forProductID: currentSub.downgradeProductID) {
                self.downgradeSub = downgradeSub
            }else{ self.downgradeSub = nil }
        }else{
            self.currentSub = nil
            self.upgradeSub = nil
            self.downgradeSub = nil
        }
        self.user = user
    }
    
    var body: some View {
                
        ZStack {
                        
            VStack(alignment: HorizontalAlignment.center, spacing: 12) {
                                                                            
                if let currentSub = self.currentSub, user.subscriptionPaymentProcessor != "apple" {
                    
                    VStack {
                        Text("You purchased \(currentSub.name) with \(user.subscriptionPaymentProcessor)")
                            .font(.system(size: 17))
                            .foregroundColor(Color("BWForeground"))
                        Text("Please proceed with cancellation on the platform on which you made the purchase.")
                            .font(.system(size: 14))
                            .foregroundColor(Color("BWForeground").opacity(0.3))
                    }
                    .padding(30)

                } else {
                    
                    List(viewModel.cellData) { cd in
                        
                        if let currentSub = self.currentSub {
                            SubscriptionCell(subscriptionTemplate: cd.template,
                                             product: cd.product,
                                             isPurchasing: (viewModel.purchasingProductID == cd.template.productID) ? true : false,
                                             isSubscribed:(cd.template.productID == currentSub.productID),
                                             tapHandlerBuy: {
                                                viewModel.purchase(subscription: cd.template)
                                             }, tapHandlerManage: {
                                                viewModel.shouldShowManageSubscription = true
                                             })
                        } else {
                            SubscriptionCell(subscriptionTemplate: cd.template,
                                             product: cd.product, isPurchasing: (viewModel.purchasingProductID == cd.template.productID) ? true : false,
                                             isSubscribed:false,
                                             tapHandlerBuy: { viewModel.purchase(subscription: cd.template) },
                                             tapHandlerManage: { viewModel.shouldShowManageSubscription = true })
                        }
                    }
                    .listStyle(PlainListStyle())
                    
                }

                Spacer()
                    
            } // end VStack
            .padding(15)
                
        } // end ZStack
        .onAppear(perform: {
            // setting properties to 'install' stateobjects onto view
            viewModel.user = self.user
        })
        .padding(0)
        .navigationBarTitle("Subscriptions")
        .navigationBarTitleDisplayMode(.inline)
    }
}
