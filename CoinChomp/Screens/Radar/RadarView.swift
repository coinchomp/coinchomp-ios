//
//  CryptoPickerView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct RadarView: View {
    
    @StateObject var viewModel = RadarViewModel()
                
    func selectCrypto(crypto: Crypto){
       // if let user = viewModel.auth.currentUser {
            if crypto.isEnabled {
                viewModel.selectedCrypto = crypto
                viewModel.isActive = true
            }
        //}else{
            //viewModel.showLogInView = true
       // }
    }
    
    var cryptoDetailLink: NavigationLink<EmptyView, CryptoDetailView>? {
        guard let crypto = viewModel.selectedCrypto else { return nil }
        return NavigationLink(
            destination: CryptoDetailView(crypto: crypto),
            isActive: $viewModel.isActive
        ) {
            EmptyView()
        }
    }
        
    var body: some View {
        NavigationView{
                        
            ZStack {
                
                cryptoDetailLink
                
                VStack(alignment: HorizontalAlignment.center,
                       spacing: 10) {

//                    Text("Select a Crypto (\(String(viewModel.cryptos.count))):")
//                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                    VStack {
                        List(viewModel.cryptos) { crypto in
                            RadarCellView(crypto: crypto,
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
            .navigationBarTitle("Radar")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                viewModel.getCryptosOnRadar()
            })
            .onDisappear(perform: {

            })
            .sheet(isPresented: $viewModel.showLogInView) {
                // blah
            } content: {
                LoginView(withMessage: nil)
            }
        }
    }
}
