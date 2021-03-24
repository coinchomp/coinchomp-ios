import SwiftUI

struct CreateLinkView: View {
    
    @StateObject var viewModel = CreateLinkViewModel()
    
    let link : Link
    @State var titleEditMode = false
    @State var contentEditMode = false
    @State var chompEditMode = false
    @State var showingChompSection = false
    
    @Binding var rootIsActive : Bool
    
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
                                if let vLink = viewModel.link,
                                   vLink.title.count == 0 {
                                    viewModel.link!.title = viewModel.titlePlaceholder
                                }
                            })
                            
                        } else {
                            Button(action: {
                                titleEditMode = true
                                contentEditMode = false
                                if let vLink = viewModel.link,
                                   vLink.title == viewModel.titlePlaceholder {
                                    viewModel.link!.title = ""
                                }
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
                                Text(link.content.count > 0 ? link.content : "(tap to enter a summary)")
                                    .font(.custom("Courier", size:15))
                                    .foregroundColor(Color("BWForeground"))
                                    .fontWeight(.light)
                                    .lineLimit(15)
                                    .lineSpacing(4)
                                    .opacity(link.content.count > 0 ? 0.75 : 0.25)
                            })
                        }
                        
                        Divider()
                        
                        Text(link.destination)
                            .font(.custom("Courier", size:13))
                            .opacity(0.3)
                            .foregroundColor(Color("BWForeground"))
                        
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
                        
                            // user needs to have at least enough chomp for an hour
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
                            } // Showing Chomp Section
                            
                            
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
                            
                            
                        } // if user has chomp
                                                                    
                        Spacer()
                                    
                        if titleEditMode == false &&
                            contentEditMode == false &&
                            chompEditMode == false {
                            
                            if viewModel.isBusy {
                                
                                Text("Submitting...")
                                    .foregroundColor(Color("BWForeground"))
                                
                            } else {
                                
                                if viewModel.didCreateLink {
                                    
                                    Text("Submitted your link!")
                                        .font(.custom("Courier", size:18))
                                        .foregroundColor(Color("CoinChompSecondary"))
                                    
                                } else {
                                    HStack {
                                        RoundRectButton(text: viewModel.submitButtonText, tapHandler: {
                                            viewModel.saveLink(){ didSucceed in
//                                                if didSucceed {
//                                                    rootIsActive = false
//                                                }
                                            }
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
                    if let vLink = viewModel.link,
                       vLink.title.count == 0 {
                        viewModel.link!.title = viewModel.titlePlaceholder
                    }
                    if link.imageURL.count > 0 {
                        viewModel.imageLoader = ImageLoader(urlString:link.imageURL)
                    }
                    viewModel.isHeadline = link.isHeadline
                })
                
            }// ScrollView
        }
    }
}
