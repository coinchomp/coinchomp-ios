//
//  FeedView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 11/27/20.
//

import SwiftUI

struct FrontPageView: View {
    
    @StateObject private var viewModel = FrontPageViewModel()
    
    @State var shouldShowLinkContent = false
    @State var shouldShowUser = false
    @State var shouldShowMenu = false

    func selectLink(link: Link){
        print(link.linkID)
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
    
    var navEditLink: NavigationLink<EmptyView, EditLinkView>? {
        guard let link = viewModel.editedLink else { return nil }
        return NavigationLink(
            destination: EditLinkView(link: link, frontPageViewModel: viewModel),
            isActive: $viewModel.isEditingLink
        ) {
            EmptyView()
        }
    }
    
    var navMenu: NavigationLink<EmptyView, MenuView>? {
        return NavigationLink(
            destination: MenuView(),
            isActive: $shouldShowMenu
        ) {
            EmptyView()
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
    
    var navReport: NavigationLink<EmptyView, ReportContentView>? {
        guard let user = viewModel.auth.currentUser else { return nil }
        guard let link = viewModel.reportedLink else { return nil }
        let view = ReportContentView(entityID: link.linkID,
                                     entityType: "link",
                                     user: user,
                                     isActive: $viewModel.isReportingLink)
        return NavigationLink(
            destination: view,
            isActive: $viewModel.isReportingLink
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                Color("BWBackground")
                .edgesIgnoringSafeArea(.all)
                
                navMenu
                navUser
                navEditLink
                navLinkContent
                navReport
                
                ScrollView(.vertical) {
                    
                    HStack {
                        
                        Spacer()
                        
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(.leading, 75)
                            .padding(.trailing, 40)
                        
                        Button(action: {
                            shouldShowMenu = true
                        }, label: {
                            Image(systemName: "circle.fill")
                                .font(.system(size:11))
                                .foregroundColor(Color("CoinChompPrimary"))
                                .padding(.trailing, 20)
                        })
                        
                    }
                    .padding(.vertical, 10)
                    
                    LazyVStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                        //ForEach(viewModel.links, id: \.self) {
                        ForEach(viewModel.links.indices, id: \.self) { i in
                            if let link = viewModel.links[i] {
                                if viewModel.hideAlreadyViewed() &&
                                    viewModel.viewedLinkIDs.contains(link.linkID) ||
                                    (link.isAd && viewModel.canHideAds()) {
                                    // show nothing
                                } else {
                                    
                                    LinkCell(link: link,
                                             fontSize: link.isHeadline ?
                                                viewModel.fontSizeForLinkTitleHeadline : viewModel.fontSizeForLinkTitle,
                                             viewed: viewModel.viewedLinkIDs.contains(link.linkID),
                                             viewModel: viewModel,
                                             action: {
                                        selectLink(link: link)
                                    })
                                    .sheet(isPresented: Binding<Bool>(
                                        get: { viewModel.isComposingTweet == true && viewModel.tweetedLink?.linkID == link.linkID },
                                        set: { _ = $0 }
                                    )) { } content: {
                                            if let user = viewModel.auth.currentUser {
                                                ComposeTweetView(tweetText: link.title, link: link, user: user, isComposingTweet: $viewModel.isComposingTweet)
                                            }
                                        }
                                    if viewModel.dividersEnabled {
                                        if (i + 1) < viewModel.links.count,
                                            let nextLink = viewModel.links[i+1]{
                                            if link.isHeadline {
                                                if nextLink.isHeadline == false {
                                                    Divider()
                                                }
                                            } else if link.topicID.count > 0 {
                                                if link.topicID != nextLink.topicID {
                                                    Divider()
                                                }
                                            } else {
                                                Divider()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                } // ScrollView
                .padding(.horizontal, 0)
                .navigationBarHidden(true)
                
            }.onAppear(perform: {
                viewModel.fetchLinks()
                viewModel.refreshFontSizes()
            })
            .onDisappear(perform: {
                clearDeepLinks()
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
