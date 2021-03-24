//
//  ReceiptCell.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 2/1/21.
//

import SwiftUI

struct ReceiptCell: View {
    
    let receipt : Receipt
    
    var body: some View {
        HStack {
            Image(systemName: "scroll")
            VStack(alignment: .leading, spacing: 5) {
                Text(receipt.description)
                    .font(.system(size:15))
                    .foregroundColor(Color("BWForeground"))

                if let subTemplate = SubscriptionService.shared.template(forProductID: receipt.productID){
                    Text(subTemplate.name)
                        .font(.system(size:11))
                        .foregroundColor(Color("BWForeground").opacity(0.25))
                }
            }
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                if let subProduct = StoreManager.shared.getProductByID(receipt.productID){
                    Text(subProduct.localizedPrice)
                        .font(.system(size:15))
                        .foregroundColor(Color("BWForeground"))
                }
                Text(receipt.getDateString())
                    .font(.system(size:12))
                    .foregroundColor(Color("BWForeground").opacity(0.4))
            }
        }
    }
}
