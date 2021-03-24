//
//  SubscriptionCell.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 2/9/21.
//

import SwiftUI
import StoreKit

struct SubscriptionCell: View  {
    
    let subscriptionTemplate : SubscriptionTemplate
    let product : SKProduct
    let isPurchasing : Bool
    let isSubscribed : Bool
    let tapHandlerBuy : ()->()
    let tapHandlerManage: ()->()
    
    var body: some View {
        
        VStack(alignment: HorizontalAlignment.leading, spacing: 10) {
            
            Text(subscriptionTemplate.name)
                .font(.system(size:22))
                .fontWeight(.bold)
                .foregroundColor(Color("BWForeground"))
            
            Text(subscriptionTemplate.summary)
                .font(.system(size:18))
                .fontWeight(.semibold)
                .lineSpacing(5)
                .foregroundColor(Color("BWForeground").opacity(0.6))
                    
            Text(subscriptionTemplate.getFeatureSummary())
                .font(.system(size:14))
                .foregroundColor(Color("BWForeground").opacity(0.75))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
            
            if isSubscribed {
                
                RoundRectButton(text: "Manage Subscription", iconName: nil, tapHandler: {
                    tapHandlerManage()
                })
                
            } else {
             
                RoundRectButton(text: isPurchasing ? "Purchasing..." : "Upgrade to \(subscriptionTemplate.name) for \(product.localizedPrice)/\(subscriptionTemplate.getShortFrequency())", foregroundColor: Color.blue.opacity(isPurchasing ? 0.4 : 0.90), backgroundColor: Color.blue.opacity(isPurchasing ? 0.05 : 0.20), iconName: nil, tapHandler: {
                    tapHandlerBuy()
                }).disabled(isPurchasing)
            }
            
        }.padding(.bottom, 10)
    }
}
