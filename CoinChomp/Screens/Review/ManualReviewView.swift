//
//  ReviewLinkView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/17/21.
//

import SwiftUI

struct ManualReviewView: View {
    
    @StateObject var viewModel = ManualReviewViewModel()
    
    let links : [Link]
    let isActive : Binding<Bool>
    @State var titleEditMode = false
    @State var contentEditMode = false
    @State var shouldShowUser = false
    
    func showUser(){
        viewModel.prepareToShowUser() { (didSucceed) in
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
                        
            //Color("CoinChompPrimary")
            
            .edgesIgnoringSafeArea(.all)
                    
            VStack(alignment: .leading, spacing: 10) {
                
                if let link = viewModel.selectedLink,
                   let titleBinding = Binding(
                    get: { viewModel.selectedLink!.title },
                    set: { viewModel.selectedLink!.title = $0 }),
                   let contentBinding = Binding(
                    get: { viewModel.selectedLink!.content },
                    set: { viewModel.selectedLink!.content = $0 }),
                    let isHeadlineBinding = Binding(
                     get: { viewModel.isHeadline },
                     set: { viewModel.isHeadline = $0 }){
                    
                        Button(action: {
                            UIApplication.shared.open(URL(string: link.destination)!)
                        }, label: {
                            Text(link.destination)
                                .foregroundColor(Color("BWForeground"))
                                .font(.custom("Courier", size:16))
                                .opacity(0.3)
                        })
                                        
                        if titleEditMode {
                        
                            TextEditor(text: titleBinding)
                                .lineLimit(2)
                                .lineSpacing(10)
                                .font(.custom("Courier", size:18))
                                .foregroundColor(Color("BWForeground"))
                                .frame(minWidth: UIScreen.main.bounds.size.width * 0.75,
                                       maxWidth: .infinity,
                                       minHeight: 0,
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
                                .font(.custom("Courier", size:15))
                                .foregroundColor(Color("BWForeground"))
                                .frame(minWidth: UIScreen.main.bounds.size.width * 0.75,
                                       maxWidth: .infinity,
                                       minHeight: 0,
                                       idealHeight: 0,
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
                    
                    
                        if let user = viewModel.auth.currentUser,
                           user.roles.contains("editor") == true {
                            Divider()
                            Toggle("Set As Headline", isOn:isHeadlineBinding)
                                .foregroundColor(Color("BWForeground"))
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
                                
                        if titleEditMode == false && contentEditMode == false {
                            
                            if viewModel.isBusy {
                                
                                Text("Performing request...")
                                    .foregroundColor(Color("BWForeground"))
                                
                            } else {
                                
                                HStack {
                                    RoundRectButton(text: "Reject", tapHandler: {
                                        viewModel.rejectLink()
                                    })
                                    Spacer()
                                    RoundRectButton(text: "Approve", tapHandler: {
                                        viewModel.approveLink()
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
                    
                } else {
                    
                    Text("Nothing to Review...")
                        .foregroundColor(Color("BWForeground"))
                    
                }
            }
            .padding(10)
            .navigationBarTitle("Review Links")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                //viewModel.links.removeAll()
                viewModel.prepareData(withLinks: links)
                //viewModel.prepareData()
            })
        }
    }
}
