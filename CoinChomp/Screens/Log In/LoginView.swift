//
//  LoginView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 11/27/20.
//

import SwiftUI

struct LoginView: View {
        
    @StateObject private var viewModel = LoginViewModel()
    
    let message: String?
                
    init(withMessage: String?){
        if let message = withMessage {
            self.message = message
        }else{
            self.message = nil
        }
    }
    
    var body: some View {
        
        NavigationView{
            
            ZStack {
                
                VStack(alignment: HorizontalAlignment.center, spacing: 10) {
                    
                    if let contextMessage = viewModel.contextMessage,
                       contextMessage.count > 0 {
                        
                            Text(contextMessage)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 20))
                                .padding(15)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.black.opacity(0.50))
                                .background(Color.yellow.opacity(0.20))
                            
                    }
                    
                    Spacer()
                    
                                        
                    if viewModel.isBusy {
                        
                        VStack(alignment: HorizontalAlignment.center, spacing: 10) {
                            Text("Just a sec...")
                                .font(.system(size:22))
                                .foregroundColor(Color("BWForeground").opacity(0.80))
                                .padding(10)
                            if viewModel.auth.isNewUser {
                                Text("Creating your new account. This can sometimes take up to 20 seconds")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size:16))
                                    .lineSpacing(5)
                                    .foregroundColor(Color("BWForeground").opacity(0.6))
                                    .frame(maxWidth:UIScreen.main.bounds.width * 0.6)
                                    .padding(15)
                            } else {
                                Text("(Loading your account)")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size:16))
                                    .lineSpacing(5)
                                    .foregroundColor(Color("BWForeground").opacity(0.6))
                                    .padding(15)
                            }
                            ProgressView()
                        }
                        
                    } else {
                        
                        if let user = viewModel.auth.currentUser  {
                            
                            VStack(alignment: HorizontalAlignment.center, spacing: 10) {
                                
                                Text("Welcome back, \(user.getName())!")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20))
                                    .foregroundColor(Color("BWForeground").opacity(0.25))
                                
                            }
                            
                        } else {
                            
                            Button(action:{
                                viewModel.logInWithTwitter()
                            },label:{
                                HStack {
                                    Image("twitterlogo-white")
                                    Text("Log in with Twitter")
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 20))
                                        .foregroundColor(Color.white)
                                }
                            })
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color(red: 29 / 255, green: 161 / 255, blue: 262 / 255))
                            .cornerRadius(8)
                            
                            
                            Text("CoinChomp is enjoyed with Twitter! Log in or join with your Twitter account by tapping the button.")
                                .multilineTextAlignment(.center)
                                .lineSpacing(4.0)
                                .font(.system(size: 16))
                                .frame(maxWidth: (UIScreen.main.bounds.size.width * 0.6))
                                .foregroundColor(Color("BWForeground").opacity(0.50))
                                .padding(10)
                        }
                    }
                    Spacer()
                }
            }
            .padding(0)
            .navigationBarTitle("Log in or Create account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: {
            viewModel.contextMessage = message
        })
    }
}
