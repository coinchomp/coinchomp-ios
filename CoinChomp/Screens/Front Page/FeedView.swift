//
//  FeedView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 11/27/20.
//

import SwiftUI

struct FrontPageView: View {
    
    @StateObject private var viewModel = FeedViewModel()
    
    @State var isBusy : Bool = false
    @State var shouldShowLinkContent = false
    @State var shouldShowUser = false

    func selectLink(link: Link){
        viewModel.recordClick(link: link)
        viewModel.selectedLink = link
        if link.content.count > 0 {
            shouldShowLinkContent = true
        } else if link.type == .Twitter {
           let screenName =  link.destination
           TwitterService.shared.navigateToScreenName(screenName:screenName)
        } else if link.type == .AppleAppStore {
           if let url = URL(string: "itms-apps://apple.com/app/id\(link.destination)") {
               UIApplication.shared.open(url)
           }
        } else {
            UIApplication.shared.open(URL(string: link.destination)!)
        }
    }
    
    func deepLinkToUser(userID: String){
        viewModel.prepareToShowUser(userID: userID) { (didSucceed) in
            if didSucceed {
                shouldShowUser = true
            }
        }
    }
    
    var navUser: NavigationLink<EmptyView, ProfileView>? {
        guard let user = viewModel.selectedUser else { return nil }
        return NavigationLink(
            destination: ProfileView(user: user),
            isActive: $shouldShowUser
        ) {
            EmptyView()
        }
    }
    
    var navLinkContent: NavigationLink<EmptyView, LinkContentView>? {
        guard let link = viewModel.selectedLink else { return nil }
        return NavigationLink(
            destination: LinkContentView(withLink: link,
                                         isActive: $shouldShowLinkContent),
            isActive: $shouldShowLinkContent
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                Color("CoinChompPrimary")
                
                .edgesIgnoringSafeArea(.all)
                
                navUser
                navLinkContent
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    Image("logo-white")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 50)
                        .padding(.bottom, 10)
                    
                    LazyVStack {
                        ForEach((viewModel.links), id: \.self) {
                            if let link = $0 {
                                LinkCell(link: link, action: {
                                    selectLink(link: link)
                                })
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                .navigationBarHidden(true)
                
            }.onAppear(perform: {
                viewModel.startListening()
            })
            .onDisappear(perform: {
                clearDeepLinks()
                viewModel.stopListening()
            })
            .onReceive(NotificationCenter.default.publisher(for:Notification.Name("needDeepLinking")), perform: {_ in
                deepLinkIfNeeded()
            })
        }
    }
    
    func deepLinkIfNeeded() {
        let defaults = UserDefaults.standard
        guard defaults.object(forKey: deepLinkPredictionIDKey) != nil ||
                defaults.object(forKey: deepLinkUserIDKey) != nil else { return }
        if let deepLinkUserID = defaults.object(forKey: deepLinkUserIDKey) as? String {
            clearDeepLinks()
            deepLinkToUser(userID: deepLinkUserID)
        }
    }
    
    func clearDeepLinks(){
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: deepLinkUserIDKey)
    }
}
