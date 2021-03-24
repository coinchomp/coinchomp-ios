//
//  ScryLabel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/21/21.
//

import SwiftUI

struct ChompLabel: View {
    
    let width : CGFloat
    let fontSize : CGFloat
    let value : Double
    @State var canShowRefunds : Bool = false
    @State var canShowSign : Bool = true
    
    private func formattedValue() -> String {
        if canShowSign == false {
            return String(abs(value).formatChomp)
        }
        if value > 0 {
            return "+" + value.formatChomp
        }
        return value.formatChomp
    }
    
    var body: some View {
        HStack(alignment:.center, spacing:3) {
            /*
            Image("scry")
                .resizable()
                .frame(width: width)
                .frame(height: width * 1.25)
             */
            Text("CHOMP \(formattedValue())")
                .font(.system(size:fontSize))
                .fixedSize()
            
            if canShowRefunds && value > 0 {
                Text("(to be refunded)")
                    .font(.system(size:fontSize * 0.75))
                    .foregroundColor(Color.black.opacity(0.4))
                    .fixedSize()
            }
        }
    }
}
