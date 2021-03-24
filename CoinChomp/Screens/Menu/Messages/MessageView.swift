//
//  MessageView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/24/21.
//

import SwiftUI

struct MessageView: View {
    let message : Message
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("From:")
                        .font(.system(size:14))
                        .foregroundColor(Color("BWForeground").opacity(0.5))
                    Text("\(message.from)")
                        .font(.system(size:14))
                        .foregroundColor(Color("BWForeground"))
                    Spacer()
                    Text("Sent \(message.dateString())")
                        .font(.system(size:11))
                        .foregroundColor(Color("BWForeground").opacity(0.5))
                        .padding(4)
                }
                Divider()
                HStack {
                    Text("Subject:")
                        .font(.system(size:14))
                        .foregroundColor(Color("BWForeground").opacity(0.5))
                    Text(message.subject)
                        .minimumScaleFactor(0.5)
                        .foregroundColor(Color("BWForeground"))
                        .font(.system(size:14))
                        .padding(4)
                    Spacer()
                }
                .padding(4)
                Divider()
                Text(message.body)
                    .lineSpacing(6)
                    .foregroundColor(Color("BWForeground"))
                    .font(.system(size:17))
                    .padding(6)
                
                
                HStack {
                    if let chomp = message.chomp {
                        ChompLabel(width: 15, fontSize: 12,
                                   value: chomp)
                            .opacity(0.75)
                    }
                }
                .padding(10)
                
                Spacer()
            }
        }
        .padding(5)
        .navigationBarTitle("Message Detail")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            if message.didOpen == false {
                message.didOpen = true
                MessagesViewModel.openMessage(message: message)
            }
        })
    }
}
