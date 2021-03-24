//
//  EditLinkView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/12/21.
//

import SwiftUI

struct EditLinkView: View {
    
    @StateObject var viewModel = EditLinkViewModel()
    
    let link : Link
    let frontPageViewModel : FrontPageViewModel
    @State var titleEditMode = false
    @State var contentEditMode = false
    @State var chompEditMode = false
    @State var shouldShowUser = false
    @State var showingChompSection = false
    
    func showUser(){
        viewModel.prepareToShowUser() { (didSucceed) in
            if didSucceed {
                shouldShowUser = true
            }
        }
    }
    
    var navUser: NavigationLink<EmptyView, ProfileView>? {
        guard let user = viewModel.curator else { return nil }
        return NavigationLink(
            destination: ProfileView(user: user),
            isActive: $shouldShowUser
        ) {
            EmptyView()
        }
    }
    
    var navSelectTopic: NavigationLink<EmptyView, SelectTopicView>? {
        guard viewModel.showSelectTopicView == true else { return nil }
        return NavigationLink(
            destination: SelectTopicView(withLink: link, isActive: $viewModel.showSelectTopicView),
            isActive: $viewModel.showSelectTopicView
        ) {
            EmptyView()
        }
    }

    var body: some View {
                        
        ZStack {
            
            navUser
            navSelectTopic
            
            ScrollView(.vertical) {

                LazyVStack(alignment: .leading, spacing: 10) {
                    
                    if viewModel.link != nil,
                       let titleBinding = Binding(
                        get: { viewModel.link!.title },
                        set: { viewModel.link!.title = $0 }),
                       let contentBinding = Binding(
                        get: { viewModel.link!.content },
                        set: { viewModel.link!.content = $0 }){
                    
                        Button(action: {
                            UIApplication.shared.open(URL(string: link.destination)!)
                        }, label: {
                            Text(link.destination)
                                .font(.custom("Courier", size:16))
                                .opacity(0.3)
                                .foregroundColor(Color("BWForeground"))
                        })
                                            
                        if titleEditMode {
                        
                            TextEditor(text: titleBinding)
                                .lineLimit(2)
                                .lineSpacing(10)
                                .foregroundColor(Color("BWForeground"))
                                .font(.custom("Courier", size:18))
                                .frame(minWidth: UIScreen.main.bounds.size.width * 0.75,
                                       maxWidth: .infinity,
                                       minHeight: 100,
                                       maxHeight: 200,
                                       alignment: .center)
                            
                            RoundRectButton(text: "Done", tapHandler: {
                                titleEditMode = false
                            })
                            
                        } else {
                            Button(action: {
                                titleEditMode = true
                                contentEditMode = false
                            }, label: {
                                Text(link.title)
                                    .font(.custom("Courier", size:20))
                                    .foregroundColor(Color("BWForeground"))
                            })
                        }
                        
                        if contentEditMode {
                            TextEditor(text: contentBinding)
                                .lineLimit(2)
                                .lineSpacing(10)
                                .foregroundColor(Color("BWForeground"))
                                .font(.custom("Courier", size:15))
                                .frame(minWidth: UIScreen.main.bounds.size.width * 0.75,
                                       maxWidth: .infinity,
                                       minHeight: 150,
                                       maxHeight: 200,
                                       alignment: .center)
                            RoundRectButton(text: "Done", tapHandler: {
                                contentEditMode = false
                            })
                        } else {
                            Button(action: {
                                contentEditMode = true
                                titleEditMode = false
                            }, label: {
                                Text(link.content.count > 0 ? link.content : "(no content)")
                                    .font(.custom("Courier", size:15))
                                    .foregroundColor(Color("BWForeground"))
                                    .fontWeight(.light)
                                    .lineLimit(15)
                                    .lineSpacing(4)
                                    .opacity(link.content.count > 0 ? 0.75 : 0.25)
                            })
                        }
                        
                        if let user = viewModel.auth.currentUser {
                           if user.roles.contains("editor") == true {
                            Divider()
                            if let vmLink = viewModel.link,
                               vmLink.imageURL.count > 0 {
                                
                                if let image = viewModel.imageLoader.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .cornerRadius(3)
                                }
                                
                                Text("Image URL: \(vmLink.imageURL)")
                                    .font(.system(size:10))
                                    .foregroundColor(Color("BWForeground").opacity(0.5))
                            }
                            RoundRectButton(text:"Paste Image URL", tapHandler:{
                                viewModel.pasteLinkImageURL()
                            })
                            Divider()
                            Toggle("Set As Headline", isOn: $viewModel.isHeadline)
                            Divider()
                            Button(action:{
                                viewModel.showSelectTopicView = true
                            }, label: {
                                HStack {
                                    Text(link.topicID.count == 0 ? "Add to Topic" : "Edit Topic")
                                        .foregroundColor(Color("BWForeground"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            })
                           }
                        
                            // user needs at least enough chomp for an hour
                            if user.chomp > (60 * 60) {
                                Divider()
                                if showingChompSection {
                                    
                                    HStack {
                                        Text("Amount to add: ")
                                        TextField("(Tap to enter amount)", text: $viewModel.chompString, onEditingChanged: { (editingChanged) in
                                                    if editingChanged {
                                                        chompEditMode = true
                                                        print("TextField focused")
                                                    } else {
                                                        print("TextField focus removed")
                                                    }
                                                })
                                        .keyboardType(.numberPad)
                                        .padding(.horizontal, 20.0)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .foregroundColor(Color("BWForeground"))
                                        .onChange(of: viewModel.chompString) { value in
                                            guard var chompDouble = Double(value) else { return }
                                            if chompDouble < 0 {
                                                chompDouble = 0
                                            }
                                            if chompDouble > user.chomp {
                                                chompDouble = user.chomp
                                            }
                                            viewModel.chompString = Int(chompDouble).description
                                         }
                                    }
                                    
                                    if viewModel.chompHint.count > 0 {
                                        Text(viewModel.chompHint)
                                            .font(.system(size:12))
                                            .foregroundColor(Color("BWForeground").opacity(0.3))
                                    }
                                    
                                    HStack {
                                        Spacer()
                                        Text("Current Balance: CHOMP \(user.chomp.formatChomp)")
                                            .font(.system(size:14))
                                            .foregroundColor(Color("BWForeground").opacity(0.4))
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.black.opacity(0.03))
                                    .foregroundColor(Color("BWForeground").opacity(0.75))
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    if chompEditMode {
                                        RoundRectButton(text: "Done", tapHandler: {
                                            chompEditMode = false
                                            Common.resignFirstResponder()
                                        })
                                    }
                                } else {
                                    RoundRectButton(text: "Boost Link", tapHandler: {
                                        showingChompSection = true
                                    })
                                    Text("Add CHOMP to boost the visibility of this link.")
                                        .font(.system(size:12))
                                        .foregroundColor(Color("BWForeground").opacity(0.3))
                                }
                            }
                        }
                                            
                       if link.hasCurator(),
                          let imageLoader = viewModel.curatorImageLoader,
                          let image = imageLoader.image {
                            
                            HStack {
                                    
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(maxWidth: 60,maxHeight: 60)
                                        .padding(0)
                                                        
                                    VStack(alignment: HorizontalAlignment.leading, spacing: 6) {
                                        Text("Curated by:")
                                            .font(.system(size:12))
                                            .italic()
                                            .foregroundColor(Color("BWForeground").opacity(0.4))
                                                             
                                        Text(link.userName)
                                            .font(.system(size: 18))
                                            .foregroundColor(Color("BWForeground"))
                                    }
                                    .padding(.leading, 10)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showUser()
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
                        
                        Spacer()
                                    
                        if titleEditMode == false &&
                            contentEditMode == false &&
                            chompEditMode == false {
                            
                            if viewModel.isBusy {
                                
                                Text("Saving...")
                                    .foregroundColor(Color("BWForeground"))
                                
                            } else {
                                
                                HStack {
                                    RoundRectButton(text: "Save", tapHandler: {
                                        viewModel.saveLink()
                                    })
                                }
                                
                                if viewModel.errorMessage.count > 0 {
                                    HStack {
                                        Image(systemName:"exclamationmark.triangle")
                                            .font(.system(size:18))
                                            .foregroundColor(Color.orange)

                                        Text(viewModel.errorMessage)
                                            .font(.custom("Courier", size:18))
                                            .foregroundColor(Color.orange)
                                    }
                                }
                            } // if busy
                        }
                    }
                }
                .padding(10)
                .navigationBarTitle("Edit Link")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: {
                    viewModel.link = link
                    if link.imageURL.count > 0 {
                        viewModel.imageLoader = ImageLoader(urlString:link.imageURL)
                    }
                    viewModel.isHeadline = link.isHeadline
                    viewModel.frontPageViewModel = frontPageViewModel
                    if frontPageViewModel.editorShowsChompSection {
                        showingChompSection = frontPageViewModel.editorShowsChompSection
                    }
                })
                
            }// ScrollView
        }
    }
}
