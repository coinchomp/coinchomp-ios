//
//  ReceiptsView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 2/1/21.
//

import SwiftUI

struct ReceiptsView: View {
    
    let user : User
    @StateObject var viewModel = ReceiptsViewModel()
    
    var body: some View {
        ZStack {
            VStack(alignment: HorizontalAlignment.center, spacing:0) {
                
                List(viewModel.receipts) { receipt in
                    ReceiptCell(receipt: receipt)
                }
                .listStyle(PlainListStyle())
            }
            .padding(0)
            .navigationBarTitle("Receipts")
            .navigationBarTitleDisplayMode(.inline)
        }.onAppear(perform: {
            viewModel.fetchReceipts(forUser: self.user)
        })
    }
}
