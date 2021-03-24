//
//  ComposeTweetView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/7/21.
//

import SwiftUI

struct ComposeTweetView: View {
    
    @StateObject private var viewModel = ComposeTweetViewModel()
    
    var tweetText: String
    var link: Link
    let user: User
    let maxLength: Int = (280 - 26 - 3) // padded for Twitter's link length
    @Binding var isComposingTweet : Bool
            
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                VStack(alignment: HorizontalAlignment.center, spacing: 10) {
                    
                    if viewModel.isBusy {
                        
                        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
                            Text("Posting Tweet...")
                                .font(.system(size:22))
                                .foregroundColor(Color("BWForeground").opacity(0.8))
                                .padding(10)
                            ProgressView()
                        }
                        
                    } else {
                        
                        if viewModel.postedTweet {
                            
                            Text("Posted tweet!")
                                .font(.system(size:15))
                                .foregroundColor(Color("BWForeground").opacity(1.0))
                                .padding(15)
                            
                            RoundRectButton(text: "Close", tapHandler: {
                                isComposingTweet = false
                            })
                            
                        } else {
                            
                            
                            if let image = viewModel.imageLoader.image {
                                HStack {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 50,maxHeight: 50)
                                        .padding(.leading, 10)
                                        .padding(.top, 10)
                                    Spacer()
                                }
                            }
                            
                                                    
                            // TextEditor
                            TextEditor(text: $viewModel.tweetText)
                                .lineLimit(2)
                                .lineSpacing(10)
                                .font(.custom("Courier", size:20))
                                .foregroundColor(Color("BWForeground").opacity(0.9))
                                .onChange(of: viewModel.tweetText) { value in
                                    if (viewModel.tweetText.count > maxLength) {
                                        viewModel.tweetText = String(viewModel.tweetText.prefix(maxLength))
                                    }
                                 }
                            
                            
                            
                            if viewModel.tweetText.count > 0 {
                                HStack {
                                    Text("\(viewModel.tweetText.count)/\(maxLength) characters")
                                        .font(.system(size:12))
                                        .foregroundColor(viewModel.tweetText.count < maxLength ? Color("BWForeground").opacity(0.5) : .red)
                                    Spacer()
                                }
                                .padding(.leading, 10)
                            }
                            
                            Divider()
                            
                            HStack {
                                
                                Image(systemName: "link")
                                    .font(.system(size:14))
                                    .foregroundColor(Color.black.opacity(0.4))
                                Text("coinchomp.com/c/\(link.linkID)")
                                    .font(.system(size:14))
                                    .foregroundColor(Color("BWForeground").opacity(0.4))
                                    .minimumScaleFactor(0.5)
                                
                                Spacer()
                            }
                            .padding(.leading, 10)
                            
                            Divider()
                            
                            
                            HStack {

                                RoundRectButton(text: "Cancel", tapHandler: {
                                    isComposingTweet = false
                                })
                                
                                Button(action:{
                                    viewModel.postTweet(withLink: link)
                                },label:{
                                    HStack {
                                        Image("twitterlogo-white")
                                        Text("Tweet It!")
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 20))
                                            .foregroundColor(Color.white)
                                    }
                                })
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color(red: 29 / 255, green: 161 / 255, blue: 262 / 255))
                                .cornerRadius(8)
                            }
                            
                            
                        } // if posted tweet
                    }
                                        
                    Spacer()
                }
            }
            .padding(0)
            .navigationBarTitle("Compose Tweet")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: {
            viewModel.imageLoader = ImageLoader(urlString:user.photoURL)
            viewModel.tweetText = tweetText
        })
    }
}
