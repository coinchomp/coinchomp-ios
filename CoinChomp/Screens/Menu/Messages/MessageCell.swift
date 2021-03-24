//
//  MessageCell.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/24/21.
//

import SwiftUI

struct MessageCell: View {
    
    let message : Message
    let deleteMode : Bool
    let tapHandler : ()->()
    
    var body: some View {
        
        Button(action: {
            self.tapHandler()
        }) {
            HStack {
                if message.didOpen {
                    Image(systemName: "envelope.open")
                        .foregroundColor(Color("BWForeground").opacity(0.25))
                } else {
                    Image(systemName: "envelope")
                        .foregroundColor(Color.blue.opacity(0.8))
                }
                if message.didOpen {
                    Text(message.subject)
                        .font(.system(size:14))
                        .foregroundColor(Color("BWForeground").opacity(0.25))
                        .lineLimit(0)
                } else {
                    Text(message.subject)
                        .font(.system(size:14))
                        .foregroundColor(Color("BWForeground"))
                        .lineLimit(0)
                }
                Spacer()
                Text(message.dateString())
                    .foregroundColor(Color("BWForeground").opacity(0.30))
                    .font(.system(size:11))
                
                if deleteMode {
                    Image(systemName: "trash")
                        .foregroundColor(Color.red)
                }
            }
        }
    }
}
