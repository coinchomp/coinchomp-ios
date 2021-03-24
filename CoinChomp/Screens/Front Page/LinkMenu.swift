//
//  LinkMenu.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/11/21.
//

import SwiftUI

struct LinkMenu: View {
    
    let link : Link
    let viewModel : FrontPageViewModel
    @State var showAlert : Bool = false
    
    var body: some View {
        
        if let user = viewModel.auth.currentUser {
            
            Button(action: {
                viewModel.tweetedLink = link
            }, label: {
                HStack {
                    Image(systemName: "message")
                    Text("Tweet This")
                }
            })
            
        }
            
        Button(action: {
            let pasteboard = UIPasteboard.general
            pasteboard.string = link.destination
        }, label: {
            HStack {
                Image(systemName: "link")
                Text("Copy Link URL")
            }
        })
        
        Button(action: {
            let pasteboard = UIPasteboard.general
            pasteboard.string = link.title
        }, label: {
            HStack {
                Image(systemName: "character")
                Text("Copy Link Title")
            }
        })
        
        if let user = viewModel.auth.currentUser {
            
            if user.userID == link.userID || user.roles.contains("editor") {
                Button(action: {
                    viewModel.editedLink = link
                }, label: {
                    HStack {
                        Image(systemName: "square.and.pencil")
                        Text("Edit Link")
                    }
                })
            }
            
            if user.roles.contains("editor") {
                Button(action: {
                    viewModel.deleteLink(link: link)
                }, label: {
                    HStack {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                        Text("Delete Link")
                            .foregroundColor(.red)
                    }
                })
            }
            
            if !viewModel.didUserAlreadyFlagLink(user: user, link: link) {
                Button(action: {
                    viewModel.reportedLink = link
                }, label: {
                    HStack {
                        Image(systemName: "flag")
                        Text("Report Link")
                    }
                })
            }
            
            if user.roles.contains("editor") && link.chomp == 0 {
                Button(action: {
                    viewModel.editorShowsChompSection = true
                    viewModel.editedLink = link
                }, label: {
                    VStack {
                        HStack {
                            Image(systemName: "arrow.up")
                            Text("Boost Link")
                        }
                    }
                })
            }
            
        }
    }
}

