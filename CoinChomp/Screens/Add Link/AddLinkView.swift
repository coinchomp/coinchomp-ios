//
//  AddLinkView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/16/21.
//

import SwiftUI

struct AddLinkView: View {
    
    @StateObject var viewModel = AddLinkViewModel()
    @State var showLogInView = false
    @State var isActive = false
    
    var navCreateLink: NavigationLink<EmptyView, CreateLinkView>? {
        guard let link = viewModel.createLink() else { return nil }
        let view = CreateLinkView(link: link, rootIsActive: $isActive)
        return NavigationLink(
            destination: view,
            isActive: $isActive
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
                            
        ZStack {
                            
            navCreateLink
                         
            VStack(alignment: .leading, spacing: 10) {
                
                if viewModel.destination.count > 0 {
                    
                    Text("Link URL:")
                        .font(.custom("Courier", size:22))
                        .fontWeight(.medium)
                        .foregroundColor(Color("BWForeground").opacity(0.9))

                    Text(viewModel.destination)
                        .foregroundColor(Color("BWForeground").opacity(0.4))

                    RoundRectButton(text: "Next", iconName:"chevron.right", isIconLeading: false, tapHandler: {
                        if (viewModel.auth.currentUser == nil) {
                            showLogInView = true
                        } else {
                            isActive = true
                        }
                    })
                    
                } else {
                    Text("Tap the button to paste a URL!")
                        .foregroundColor(Color("BWForeground").opacity(0.75))
                }
                
                Spacer()
                
                RoundRectButton(text: "Paste", tapHandler: {
                    viewModel.getClipboardString()
                })
                .opacity((viewModel.destination.count > 0) ? 0.5 : 1.0)
                
            } // VStack
            .padding(20)
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   minHeight: 0,
                   maxHeight: .infinity,
                   alignment: .topLeading)
            .navigationBarTitle("Step 1/3: Paste a URL")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .onAppear(perform: {
                viewModel.destination = ""
            })
            .sheet(isPresented: $showLogInView ) {
                // ..
            } content: {
                LoginView(withMessage: nil)
            }
        } // ZStack
    }
}
