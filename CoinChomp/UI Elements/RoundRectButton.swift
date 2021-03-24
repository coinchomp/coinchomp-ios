//
//  RoundRectButton.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/22/21.
//

import SwiftUI

struct RoundRectButton: View {
   
    let text : String
    @State var foregroundColor : Color = Color("BWForeground").opacity(0.8)
    @State var backgroundColor : Color = Color("BWForeground").opacity(0.125)
    @State var iconName : String? = nil
    @State var fontSize : CGFloat = 16
    @State var padding : CGFloat = 12
    @State var isIconLeading: Bool = true
    let tapHandler : ()->()
    
    var body: some View {
        Button(action: {
            tapHandler()
        }) {
            HStack(alignment:.center, spacing:4) {
                
                if isIconLeading {
                    if let iconName = self.iconName {
                        Image(systemName: iconName)
                            .font(.system(size: fontSize))
                            .foregroundColor(foregroundColor)
                    }
                }
                
                Text(text)
                    .font(.system(size:fontSize))
                    .fixedSize()
                    .foregroundColor(foregroundColor)
                
                if isIconLeading == false {
                    if let iconName = self.iconName {
                        Image(systemName: iconName)
                            .font(.system(size: fontSize))
                            .foregroundColor(foregroundColor)
                    }
                }
                            
            }
            .padding(padding)
            .frame(maxHeight:60)
            .background(backgroundColor)
            .cornerRadius(10)
        }
    }
}
