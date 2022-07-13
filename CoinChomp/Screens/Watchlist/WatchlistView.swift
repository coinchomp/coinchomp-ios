//
//  CryptoPickerView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct WatchlistView: View {
    
    @StateObject var viewModel = WatchlistViewModel()
                
    func selectCrypto(crypto: Crypto){
        if viewModel.auth.currentUser == nil {
            viewModel.showLogInView = true
        }else{
            if crypto.isEnabled {
                viewModel.selectedCrypto = crypto
                viewModel.isActive = true
            }
        }
    }
        
    var body: some View {
        NavigationView{
            ZStack {
                
                VStack(alignment: HorizontalAlignment.center,
                       spacing: 10) {

                    Text("Select a Crypto (\(String(viewModel.cryptos.count))):")
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                    VStack {
                        List(viewModel.cryptos) { crypto in
                            WatchlistCellView(crypto: crypto,
                                             enabled: crypto.isEnabled,
                                             action: {
                                                selectCrypto(crypto: crypto)
                                             })
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .background(Color.gray.opacity(0.10))

            }
            .padding(0)
            .navigationBarTitle("Prediction Step 1/5")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                if let userID = viewModel.auth.currentUserID {
                    viewModel.startListening(userID: userID)
                } else {
                    viewModel.startListening(userID: nil)
                }
            })
            .onDisappear(perform: {
                viewModel.stopListening()
            })
            .sheet(isPresented: $viewModel.showLogInView) {
                // blah
            } content: {
                LoginView(withMessage: nil)
            }
        }
    }
}
