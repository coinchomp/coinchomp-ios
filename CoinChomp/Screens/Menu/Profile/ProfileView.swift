//
//  ProfileView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel = ProfileViewModel()
    
    @StateObject var storeManager = StoreManager.shared
    
    @ObservedObject var imageLoader : ImageLoader

    let user : User
    
    @State var shouldShowManageSubscription = false
    @State var shouldShowCompareSubscriptions = false
    
    init(user: User){
        self.user = user
        self.imageLoader = ImageLoader(urlString:user.photoURL)
        //UITableView.appearance().backgroundColor = UIColor(Color("CoinChompPrimary"))
    }
    
    var navManageSubscription: NavigationLink<EmptyView, ManageSubscriptionView>? {
        guard let view = ManageSubscriptionView(user: user) else { return nil }
        return NavigationLink(
            destination: view,
            isActive: $shouldShowManageSubscription
        ) {
            EmptyView()
        }
    }
    
    var navCompareSubscriptions: NavigationLink<EmptyView, CompareSubscriptionsView>? {
        let view = CompareSubscriptionsView(user: user)
        return NavigationLink(
            destination: view,
            isActive: $shouldShowCompareSubscriptions
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        
        ZStack {
            
            navManageSubscription
            navCompareSubscriptions
            
            VStack(alignment: HorizontalAlignment.center, spacing: 0) {
                
                HStack {
                    Image(uiImage: imageLoader.image ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxWidth: 100,maxHeight: 100)
                                    .padding(0)
                                        
                    VStack(alignment: HorizontalAlignment.leading, spacing: 6) {
                        Text(user.getName())
                            .font(.system(size: 18))
                        Text("Last seen \(user.lastSeenAt.timeAgoDisplay())")
                            .font(.system(size:12))
                            .italic()
                            .opacity(0.25)
                    }
                    .padding(.leading, 15)
                                        
                    if let twitterScreenName = user.twitterScreenName {
                        Button(action: {
                            TwitterService.shared.navigateToScreenName(screenName: twitterScreenName)
                        }, label: {
                            Image("twitterlogo-blue")
                                .padding(.leading, 15)
                        })
                    }
                                                            
                } // HStack
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Form {
                
                    Section() {
                        
                        HStack {
                            Text("Curator Quality Score:")
                            Spacer()
                            if (user.scorePercentile > 25){
                                Text("\(user.getScorePercentileSummary())")
                                    .foregroundColor(Color.black.opacity(0.28))
                                    .font(.system(size:12))
                                    .italic()
                            }
                            Text("\(user.score, specifier: "%.2f")")
                        }
                        
                        HStack(alignment: .center, spacing: 5) {
                            Text("Chomp:")
                            Spacer()
                            if let currentUserID = viewModel.auth.currentUserID,
                               currentUserID == self.user.userID {
                                Text("CHOMP")
                                    .foregroundColor(Color.black.opacity(0.28))
                                    .font(.system(size:11))
                                Text(user.chomp.formatChomp)
                            } else {
                                Text("(private)")
                                    .foregroundColor(Color.black.opacity(0.25))
                            }
                        }
                        
                        
                        
                    }
                    
                    
                    /*
                
                    if let currentUser = viewModel.auth.currentUser,
                       currentUser.userID == user.userID {
                        if user.isPaid {
                            if let currentSub = storeManager.currentSubscription(forUser: user) {
                                Section(header: Text("Account").foregroundColor(Color("BWForeground")), footer: Text(currentSub.getFeatureSummary())) {
                                    HStack {
                                        Text("Plan:")
                                        Spacer()
                                        Button(action: {
                                            shouldShowManageSubscription = true
                                        }){
                                            HStack {
                                                Text("\(currentSub.name)")
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                        .foregroundColor(.black)
                                    }
                                } // end section
                            } // end if/let
                        } else {
                            Section(header: Text("Account").foregroundColor(Color("BWForeground")), footer: Text("Upgrade for more cool features!").foregroundColor(Color("BWForeground"))) {
                                HStack {
                                    Text("Plan:")
                                    Text("Free")
                                        .foregroundColor(Color.black.opacity(0.4))
                                    Spacer()
                                    Button(action:{
                                        shouldShowCompareSubscriptions = true
                                    },label:{
                                        if viewModel.isPurchaseInProgress {
                                            HStack{
                                                ProgressView()
                                                Text("Upgrading...")
                                            }
                                        } else {
                                            HStack{
                                                Text("Upgrade")
                                                Image(systemName: "chevron.right")
                                            }
                                        }
                                    })
                                } // HStack
                            } // Section
                        } // isPaid if/else
                    }// isCurrentUser if/else
 
                */
 
 
                }// Form
                .foregroundColor(Color("BWForeground").opacity(0.75))
            } // VStack
            .padding(0)
            .onAppear(perform: {
                viewModel.installed = true
                viewModel.isPurchaseInProgress = false
            })
        } // ZStack
        .navigationBarTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .navigationBarItems(trailing: Button(action: {
            if let currentUser = viewModel.auth.currentUser,
                   currentUser.userID == user.userID,
                   user.canPullDataFromSocialProfile() == true {
                viewModel.refreshProfile(userID: user.userID)
            }
        }) {
            if let currentUser = viewModel.auth.currentUser,
                   currentUser.userID == user.userID,
                   user.canPullDataFromSocialProfile() == true {
                Text(viewModel.isBusy ? "Refreshing..." : "Refresh")
                    .fontWeight(.light)
                    .opacity(0.5)
            } else {
                Text("")
            }
        })
    }
}

