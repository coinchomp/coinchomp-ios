//
//  CryptoDetailView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 10/3/21.
//

import SwiftUI

struct CryptoDetailView: View {
    
    @ObservedObject var imageLoader : ImageLoader

    @StateObject var viewModel = CryptoDetailViewModel()
    
    var crypto : Crypto

    init(crypto: Crypto){
        self.crypto = crypto
        if crypto.logoURL.isEmpty == false {
            imageLoader = ImageLoader(urlString:crypto.logoURL)
        } else {
            imageLoader = ImageLoader()
        }
    }

    
    var body: some View {
        
        ZStack {
            
            VStack {
                
                HStack {
                    
                    if let image = imageLoader.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30,
                                   height: 30,
                                   alignment: Alignment.leading)
                    }
                
                    Text(verbatim: crypto.name)
                        .font(.headline)
                    
                    Spacer()
                    
                }
                
                HStack {
                    
                    Text("This project is currently dipped more than 30% since ATH")
                            .foregroundColor(.gray)
                            .font(.footnote)
                    
                    RoundRectButton(text: "View", foregroundColor: Color.white, backgroundColor: Color("CoinChompSecondary"),
                                    fontSize: 12,
                                    padding: 10,
                                    isIconLeading: false,
                                    tapHandler: {
                                        UIApplication.shared.open(URL(string: "https://coinmarketcap.com/currencies/" + crypto.slug)!)
                                    })
                    
                }
                
                
                
                Spacer()
                
            }.padding(15)
        }
    }
}
