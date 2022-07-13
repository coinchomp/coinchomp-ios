//
//  PreferencesView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 3/7/20.
//

import SwiftUI

struct PreferencesView: View {
    
    @ObservedObject var viewModel = PreferencesViewModel()
    
    init(){
        //UITableView.appearance().backgroundColor = UIColor(Color("CoinChompPrimary"))
    }
    
    var body: some View {
            
            ZStack {
                
                VStack(alignment: HorizontalAlignment.leading,
                       spacing: 10) {
                    
                    Form {
                                                
                        Section(header: Text("Reading").font(.system(size: viewModel.fontSizeForBody))) {
                            
                            HStack {
                                //Image(systemName: "textformat.size")
                                Text("Text Size")
                                    .font(.system(size: viewModel.fontSizeForBody))
                                    .foregroundColor(Color("BWForeground"))

                                Slider(value: $viewModel.textSize,
                                       in: 0.8...1.6,
                                       step: 0.1).accentColor(Color("CoinChompSecondary"))
                            }
                            
                            HStack {
                                Text("Line Separators")
                                    .font(.system(size: viewModel.fontSizeForBody))
                                    .foregroundColor(Color("BWForeground"))

                                Spacer()
                                Toggle("Front Page Dividers", isOn: $viewModel.frontPageDividersEnabled).labelsHidden()
                                    .foregroundColor(Color("BWForeground"))

                            }
                            
                            HStack {
                                Text("Mark Already Viewed Items")
                                    .font(.system(size: viewModel.fontSizeForBody))
                                    .foregroundColor(Color("BWForeground"))

                                Spacer()
                                Toggle("Mark Already Viewed Links", isOn: $viewModel.markAlreadyViewedLinks).labelsHidden()
                                    .foregroundColor(Color("BWForeground"))

                            }
                            
                            HStack {
                                Text("Hide Already Viewed Items")
                                    .font(.system(size: viewModel.fontSizeForBody))
                                    .foregroundColor(Color("BWForeground"))

                                Spacer()
                                Toggle("Hide Already Viewed Links", isOn: $viewModel.hideAlreadyViewedLinks).labelsHidden()
                                    .foregroundColor(Color("BWForeground"))

                            }
                            
                        }
                        
                        if let user = viewModel.auth.currentUser,
                           user.roles.contains("curator") {
                            
                            Section(header:Text("Curating").font(.system(size: viewModel.fontSizeForBody))){
                                
                                HStack {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: viewModel.fontSizeForBody))

                                    Text("Auto Paste URLs")
                                        .font(.system(size: viewModel.fontSizeForBody))
                                        .foregroundColor(Color("BWForeground"))


                                    Spacer()
                                    Toggle("Auto Paste URLs", isOn: $viewModel.autoPasteEnabled).labelsHidden()
                                        .foregroundColor(Color("BWForeground"))

                                
                                }
                            }
                            
                            
                            if let user = viewModel.auth.currentUser,
                               user.isPaid {
                                
                                Section(header:Text("Subscriber Preferences").font(.system(size: viewModel.fontSizeForBody))){
                                    
                                    HStack {
                                        Image(systemName: "eye.slash")
                                            .font(.system(size: viewModel.fontSizeForBody))

                                        Text("Hide Ads")
                                            .font(.system(size: viewModel.fontSizeForBody))
                                            .foregroundColor(Color("BWForeground"))

                                        Spacer()
                                        Toggle("Hide Ads", isOn: $viewModel.hideAdsEnabled).labelsHidden()
                                            .foregroundColor(Color("BWForeground"))
                                    
                                    }
                                }
                            }
                        }
                        
                    } // Form
                    .foregroundColor(Color("BWForeground").opacity(0.75))
            }
            .padding(0)
            .navigationBarTitle("Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
