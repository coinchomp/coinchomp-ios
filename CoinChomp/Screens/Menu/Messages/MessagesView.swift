//
//  MessagesView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/23/21.
//

import SwiftUI

struct MessagesView: View {
    
    @StateObject var viewModel = MessagesViewModel()
    
    @State var selectedMessage : Message? = nil
    
    @State var deleteMode = false
    
    func selectMessage(message: Message){
        self.selectedMessage = message
    }
    
    var navLinkDetail: NavigationLink<EmptyView, MessageView>? {
        guard let selectedMessage = self.selectedMessage else { return nil }
        let view = MessageView(message:selectedMessage)
        let link = NavigationLink(destination: view,
            isActive:  Binding<Bool>(
                get: { self.selectedMessage != nil },
                set: { _ = $0 }
            )
        ) {
            EmptyView()
        }
        .isDetailLink(false)
        return link as? NavigationLink<EmptyView, MessageView>
    }
    
    var body: some View {
        ZStack {
            navLinkDetail
            VStack {
                List(viewModel.messages) { message in
                    
                    MessageCell(message: message, deleteMode: deleteMode, tapHandler: {
                        if deleteMode {
                            MessagesViewModel.deleteMessage(message: message)
                        } else {
                            selectMessage(message: message)
                        }
                    })
                    
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding(0)
        .navigationBarTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                        Button(action: {
                            deleteMode = !deleteMode
                        }) {
                            if viewModel.messages.count > 0 {
                                if deleteMode {
                                    Text("Cancel")
                                } else {
                                    Text("Delete")
                                }
                            }
                        }
                    )
        .onAppear(perform: {
            guard let userID = viewModel.auth.currentUserID else { return }
            viewModel.startListening(forUserID: userID)
            if self.selectedMessage != nil {
                self.selectedMessage = nil
            }
            if deleteMode == false {
                if viewModel.messages.count == 0 {
                    deleteMode = false
                }
            }
        })
        .onDisappear(perform: {
            viewModel.stopListening()
        })
    }
}
