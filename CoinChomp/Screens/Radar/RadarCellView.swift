//
//  CryptoCell.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct RadarCellView: View {
    
    @ObservedObject var imageLoader : ImageLoader
    
    let crypto : Crypto
    let buttonAction : ()->()
        
    init(crypto: Crypto,
         action: @escaping ()->()){
        self.crypto = crypto
        self.buttonAction = action
        if crypto.logoURL.isEmpty == false {
            imageLoader = ImageLoader(urlString:crypto.logoURL)
        } else {
            imageLoader = ImageLoader()
        }
    }
    
    var body: some View {
        
        Button(action: self.buttonAction ) {
            
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
                
                    if crypto.isEnabled == true {
                        
                        Text("(\(crypto.symbol))")
                            .foregroundColor(.gray)
                            .opacity(0.75)
                        Spacer()
                        if(crypto.onRadarHidden){
                            Text("(premium)")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                        }else{
                            Text("$\(crypto.lastQuoteUSDDouble(), specifier: crypto.priceFormatSpecifier())")
                                    .foregroundColor(.gray)
                                    .font(.footnote)
                        }
                        
                    } else {
                        Text("current prediction must resolve before making another one.")
                            .font(.custom("Courier", size: 14))
                            .foregroundColor(.gray)
                            .lineSpacing(1.25)
                            .lineLimit(3)
                    }
                }
            .frame(minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 0,
                    maxHeight: 55,
                    alignment: .leading
            )
        }
  }
}

struct RadarCryptoCellView_Previews: PreviewProvider {
    static let crypto = Crypto(databaseRecordID:"123",
                                               name: "Test",
                                               symbol: "TST",
                                               slug: "test",
                                               logoURL: "https://s2.coinmarketcap.com/static/img/coins/64x64/1680.png",
                                               volume24h: 123123.0,
                                               marketCap: 123123.0,
                                               lastQuoteUSD: "12312",
                                               lastQuoteAt: Date())
    static var previews: some View {
        RadarCellView(crypto: crypto,
                      action: {})
    }
}
