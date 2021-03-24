//
//  LinkContentView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/16/21.
//

import SwiftUI

struct LinkContentView: View {
    
    let link : Link
    let isActive : Binding<Bool>
    
    @ObservedObject var curatorImageLoader : ImageLoader
    
    @ObservedObject var linkImageLoader : ImageLoader

    @StateObject var viewModel = LinkContentViewModel()
    
    @State var shouldShowUser = false
    
    let tweetText : String
    
    init(withLink link: Link, isActive: Binding<Bool>){
        self.link = link
        self.isActive = isActive
        self.curatorImageLoader = ImageLoader(urlString:link.userPhotoURL)
        self.linkImageLoader = ImageLoader(urlString:link.imageURL)
        self.tweetText = link.title
    }
    
    func showUser(userID: String){
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
    
    var body: some View {
        
        ZStack {
            
            navUser
            
            ScrollView(.vertical) {

                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    if let image = linkImageLoader.image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .padding(0)
                    }
                    
                    Text(link.title)
                        .font(.custom("Courier", size: viewModel.fontSizeForHeading))
                        .fontWeight(.medium)
                        .foregroundColor(Color("BWForeground"))
                        .padding(10)
                    
                    Text(link.content)
                        .font(.custom("Courier", size: viewModel.fontSizeForBody))
                        .fontWeight(.light)
                        .foregroundColor(Color("BWForeground"))
                        .lineLimit(15)
                        .lineSpacing(4)
                        .opacity(0.75)
                        .padding(10)
                    
                    HStack {
                        
                        RoundRectButton(text: "Back", iconName: "chevron.left", fontSize: viewModel.fontSizeForBody, padding: 16, isIconLeading: true, tapHandler: {
                            isActive.wrappedValue = false
                        })
                        
                        RoundRectButton(text: "Read it", foregroundColor: Color.white, backgroundColor: Color("CoinChompPrimary"), iconName: "link", fontSize: viewModel.fontSizeForBody, padding: 16, isIconLeading: false, tapHandler: {
                            UIApplication.shared.open(URL(string: link.destination)!)
                        })
                        
                        
                        if viewModel.canTweet,
                           viewModel.postedTweet == false,
                           let user = viewModel.auth.currentUser {
                            RoundRectButton(text: "Tweet it", foregroundColor: Color.white, backgroundColor: Color("CoinChompSecondary"), fontSize: viewModel.fontSizeForBody, padding: 16, isIconLeading: false, tapHandler: {
                                viewModel.isComposingTweet = true
                            })
                            .sheet(isPresented: $viewModel.isComposingTweet ) {
                                // ..
                            } content: {
                                ComposeTweetView(tweetText: tweetText, link: link, user: user, isComposingTweet: $viewModel.isComposingTweet)
                            }
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 20)
                    
                    if viewModel.postedTweet{
                        HStack {
                            Spacer()
                            Text("You tweeted this!")
                                .font(.custom("Courier", size: viewModel.fontSizeForCaption))
                                .lineLimit(15)
                                .lineSpacing(4)
                                .foregroundColor(Color("CoinChompSecondary"))
                                .padding(10)
                            Spacer()
                        }
                    }

                    if !viewModel.isBusy {
                                                            
                        HStack {
                            
                            HStack {
                                Button(action: {
                                    viewModel.recordVoteUp()
                                }, label: {
                                    Spacer()
                                    if let voteType = viewModel.selectedVoteType,
                                       voteType == UserVoteType.Up {
                                        Image(systemName: "hand.thumbsup.fill")
                                            .font(.custom("Courier", size: viewModel.fontSizeForCaption))
                                            .foregroundColor(Color.blue.opacity(0.6))
                                            .padding(10)
                                    } else {
                                        Image(systemName: "hand.thumbsup")
                                            .font(.custom("Courier", size: viewModel.fontSizeForCaption))
                                            .foregroundColor(Color("BWForeground").opacity(0.4))
                                            .padding(10)
                                    }
                                    Spacer()
                                }).disabled(viewModel.isBusy)
                            }
                            .padding(0)
                            .background(Color("BWForeground").opacity(0.04))
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0, maxHeight: 40,
                                   alignment: .bottomLeading)
                                                                                
                            HStack {
                                Button(action: {
                                    viewModel.recordVoteDown()
                                }, label: {
                                    Spacer()
                                    if let voteType = viewModel.selectedVoteType,
                                       voteType == UserVoteType.Down {
                                        Image(systemName: "hand.thumbsdown.fill")
                                            .font(.custom("Courier", size: viewModel.fontSizeForCaption))
                                            .foregroundColor(Color.blue.opacity(0.6))
                                            .padding(10)
                                    } else {
                                        Image(systemName: "hand.thumbsdown")
                                            .font(.custom("Courier", size: viewModel.fontSizeForCaption))
                                            .foregroundColor(Color("BWForeground").opacity(0.4))
                                            .padding(10)
                                    }
                                    Spacer()
                                }).disabled(viewModel.isBusy)
                            }
                            .padding(0)
                            .background(Color("BWForeground").opacity(0.06))
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0, maxHeight: 40,
                                   alignment: .bottomLeading)
                            
                        } // HStack (thumbs up/down)
                        .padding(0)
                        
                        if let voteType = viewModel.selectedVoteType{
                            Text("You \(voteType.rawValue)voted this")
                                .font(.system(size:viewModel.fontSizeForCaption))
                                .foregroundColor(Color("BWForeground").opacity(0.35))
                                .padding(10)
                        }
                        
                    } else { // If not busy

                        Text("Just a sec...")
                            .font(.system(size:11))
                            .foregroundColor(Color("BWForeground").opacity(0.35))
                            .padding(10)
                    }
                    
                    
                                                                
                    if link.hasCurator() {
                 
                        Spacer()
                        
                        HStack {
                                
                                Image(uiImage: curatorImageLoader.image ?? UIImage())
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: 60,maxHeight: 60)
                                                .padding(0)
                                                    
                                VStack(alignment: HorizontalAlignment.leading, spacing: 6) {
                                    Text("Curated by:")
                                        .font(.system(size:viewModel.fontSizeForCaption))
                                        .italic()
                                        .foregroundColor(Color("BWForeground").opacity(0.4))
                                                         
                                    Text(link.userName)
                                        .foregroundColor(Color("BWForeground"))
                                        .font(.system(size: 18))
                                }
                                .padding(.leading, 10)
                                
                                Spacer()
                                
                                Button(action: {
                                    showUser(userID: link.userID)
                                }, label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("BWForeground"))
                                        .padding(10)
                                })
                                                                    
                            } // HStack (curator)
                            .padding(0)
                            .background(Color("BWForeground").opacity(0.10))
                            .frame(minWidth: 0,
                                   maxWidth: .infinity,
                                   minHeight: 0, maxHeight: 60,
                                   alignment: .bottomLeading)
                        
                                            
                        } // if link.hasCurator()
                    
                } // VStack
                .padding(0)
                .navigationBarHidden(true)
                .onAppear(perform: {
                    viewModel.setLink(link)
                    viewModel.recordImpression()
                    viewModel.refreshFontSizes()
                })
                
            } // ScrollView
        }
    }
}
