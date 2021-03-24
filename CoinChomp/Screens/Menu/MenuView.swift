//
//  MenuView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/7/20.
//

import SwiftUI

struct MenuView: View {
    
    @StateObject var viewModel = MenuViewModel()
        
    var navPrefs: NavigationLink<EmptyView, PreferencesView>? {
        let view = PreferencesView()
        return NavigationLink(destination: view,
            isActive:  $viewModel.showPreferences
        ) {
            EmptyView()
        }
    }
    
    var navProfile: NavigationLink<EmptyView, ProfileView>? {
        guard let user = viewModel.auth.currentUser else { return nil }
        let profileView = ProfileView(user: user)
        return NavigationLink(destination: profileView,
            isActive:  $viewModel.showProfile
        ) {
            EmptyView()
        }
    }
    
    var navTopics: NavigationLink<EmptyView, TopicsView>? {
        let view = TopicsView()
        return NavigationLink(destination: view,
            isActive:  $viewModel.showTopics
        ) {
            EmptyView()
        }
    }
    
    var navMessages: NavigationLink<EmptyView, MessagesView>? {
        return NavigationLink(destination: MessagesView(),
                                  isActive:  $viewModel.showMessages
        ) {
            EmptyView()
        }
    }
    
    var navAddLink: NavigationLink<EmptyView, AddLinkView>? {
        return NavigationLink(destination: AddLinkView(),
                                  isActive:  $viewModel.showAddLink
        ) {
            EmptyView()
        }
    }
    
    var navReview: NavigationLink<EmptyView, BulkSelectLinksView>? {
        return NavigationLink(
            destination: BulkSelectLinksView(),
            isActive: $viewModel.showReview
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
            
            ZStack {
                                
                navProfile
                navPrefs
                navMessages
                navAddLink
                navTopics
                navReview
                
                Color("BWBackground")
                
                VStack(alignment: HorizontalAlignment.leading,
                       spacing: 10) {
                    
                    Form {
                                                
                        Section {
                            
                            if viewModel.auth.currentUser != nil {
                            
                                Button(action: {
                                    viewModel.showProfile = true
                                }){
                                    HStack {
                                        
                                        if let imageLoader = viewModel.imageLoader,
                                           let image = imageLoader.image {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: 30,maxHeight: 30)
                                                .cornerRadius(3)
                                                .padding(0)
                                                .font(.system(size: viewModel.fontSizeForBody))
                                        } else {
                                            Image(systemName: "person")
                                                .font(.system(size: viewModel.fontSizeForBody))
                                        }
                                        
                                        Text("Your Profile")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                }
                                
                                Button(action: {
                                    viewModel.showMessages = true
                                }){
                                    HStack {
                                        Image(systemName: "envelope")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Messages")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                }
                                
                                Button(action: {
                                    viewModel.auth.logOut()
                                }){
                                    HStack {
                                        Image(systemName: "arrow.left.circle.fill")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Log out")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                    }
                                }
                                
                            } else {
                                
                                Button(action: {
                                    viewModel.showLogInView = true
                                }){
                                    HStack {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Log in or Create account")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                    }
                                }
                            }
                        }
                        
                        Section(header: Text("Curate")
                                    .foregroundColor(Color("BWForeground"))
                                .font(.system(size: viewModel.fontSizeForBody)),
                                footer: Text("Add links to news or articles to CoinChomp!")
                                    .foregroundColor(Color("BWForeground").opacity(0.5))
                                .font(.system(size: viewModel.fontSizeForCaption))){
                            Button(action: {
                                viewModel.showAddLink = true
                            }){
                                HStack {
                                    Image(systemName: "link")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                    Text("Submit a link")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: viewModel.fontSizeForBody))
                                }
                            }
                        }
                        
                        if let user = viewModel.auth.currentUser,
                           user.roles.contains("editor") {
                            Section(header: Text("Editor").foregroundColor(Color("BWForeground"))
                                        .font(.system(size: viewModel.fontSizeForBody))){
                               
                                Button(action: {
                                    viewModel.showReview = true
                                }){
                                    HStack {
                                        Image(systemName: "square.3.stack.3d")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Review Links")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                }
                                            
                                
                                Button(action: {
                                    viewModel.showTopics = true
                                }){
                                    HStack {
                                        Image(systemName: "rectangle.3.offgrid.bubble.left")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Manage Topics")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                }
                            }
                        }
                        
                        Section {
                            Button(action: {
                                viewModel.showPreferences = true
                            }, label: {
                                HStack {
                                    Image(systemName: "slider.vertical.3")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                    Text("Preferences")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                }
                            })
                        }
                                                                        
                        Section(footer: Text("\(viewModel.versionInfo) \(viewModel.envContext)").foregroundColor(Color("BWForeground").opacity(0.25)).font(.system(size: viewModel.fontSizeForBody))
){
                            
                            HStack {
                                Text("Terms of Use")
                                    .font(.system(size: viewModel.fontSizeForBody))

                                Spacer()
                                Button(action: {
                                    if let url = URL(string: "https://coinchomp.com/terms") {
                                        UIApplication.shared.open(url)
                                    }
                                }, label: {
                                    HStack {
                                        Image(systemName:"link")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                })
                            }
                            
                            HStack {
                                Text("Privacy Policy")
                                    .font(.system(size: viewModel.fontSizeForBody))

                                Spacer()
                                Button(action: {
                                    if let url = URL(string: "https://coinchomp.com/privacy-policy") {
                                        UIApplication.shared.open(url)
                                    }
                                }, label: {
                                    HStack {
                                        Image(systemName:"link")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                    }
                                })
                            }
                            
                            HStack {
                                Text("Bugs/Suggestions?")
                                    .font(.system(size: viewModel.fontSizeForBody))

                                Spacer()
                                Button(action: {
                                    TwitterService.shared.navigateToScreenName(screenName:"CoinChomp")
                                }, label: {
                                    Text("@CoinChomp")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                })
                            }
                        } // Section
                    } // Form
                    .foregroundColor(Color("BWForeground").opacity(0.75))
            }
            .padding(0)
            .navigationBarTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                viewModel.refreshEnvContext()
                viewModel.refreshFontSizes()
                viewModel.setUser()
            })
            .sheet(isPresented: $viewModel.showLogInView ) {
                // ..
            } content: {
                LoginView(withMessage: nil)
            }
        }
    }
}
