//
//  WalletView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 7/13/22.
//

import SwiftUI

struct WalletView: View {
    var body: some View {
        NavigationView{
            
            ZStack {
                
                Color("BWBackground")
                .edgesIgnoringSafeArea(.all)
                
                ScrollView(.vertical) {
                    
                    HStack {
                        
                        Image(systemName: "BitcoinLogo")
                        Text("Bitcoin")
                        
                    }
                    .background(Color.gray)
                    .frame(width: .infinity, height: 60, alignment: .center)
                }
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
    }
}
