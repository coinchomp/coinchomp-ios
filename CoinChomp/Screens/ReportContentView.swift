//
//  ReportContentView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/18/21.
//

import SwiftUI

struct ReportReason : Identifiable {
    let id = UUID()
    let text : String
}

class ReportContentViewModel : ObservableObject {

    @Published var isBusy : Bool = false
    @Published var didSucceed : Bool = false
    @Published var errorMessage : String = ""
    @Published var isActive : Binding<Bool>?
    @Published var selectedReason : String = ""
    @Published var reasons : [ReportReason] = [
        ReportReason(text:"This is spam"),
        ReportReason(text:"It's offensive"),
        ReportReason(text:"It's duplicate content")
    ]
    
    func goBack(){
        self.isActive?.wrappedValue = false
    }
    
    func sendReport(fromUser user: User,
                    entityID: String,
                    entityType: String) {
        errorMessage = ""
        isBusy = true
        var data : [String:String] = [:]
        data["userID"] = user.userID
        data["entityID"] = entityID
        data["entityType"] = entityType
        data["reason"] = selectedReason
        FlagService.shared.flagContent(data: data) { [weak self] (didSucceed) in
            self?.isBusy = false
            self?.didSucceed = didSucceed
            if !didSucceed {
                self?.errorMessage = "There was an error. Please try again later"
            }
        }
    }
}

struct ReportContentView: View {
    
    let isActive : Binding<Bool>?
    let entityID: String
    let entityType : String
    let user : User
    
    @StateObject var viewModel = ReportContentViewModel()
    
    init(entityID: String, entityType: String, user: User, isActive: Binding<Bool>){
        self.entityID = entityID
        self.entityType = entityType
        self.user = user
        self.isActive = isActive
    }
    
    var body: some View {
        
        ZStack {
            
            VStack(alignment:.leading, spacing: 10) {
                
                if viewModel.isBusy {
                    ProgressView()
                }else{
                    
                    if viewModel.didSucceed {
                        Text("Thanks for reporting this.")
                            .foregroundColor(Color("BWForeground"))

                        RoundRectButton(text: "Go Back", tapHandler: {
                            viewModel.goBack()
                        })
                        
                    } else {
                        
                        Text("Select the reason you are reporting this and tap the button send.")
                            .foregroundColor(Color("BWForeground"))
                        
                        List(viewModel.reasons) { reason in
                            
                            HStack {
                                Button(action:{
                                    if reason.text == viewModel.selectedReason {
                                        viewModel.selectedReason = ""
                                    }else {
                                        viewModel.selectedReason = reason.text
                                    }
                                },
                               label: {
                                Image(systemName: viewModel.selectedReason == reason.text ? "checkmark.square" : "square")
                               })
                                Text(reason.text)
                                    .foregroundColor(Color("BWForeground"))

                                Spacer()
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        if viewModel.errorMessage.count > 0 {
                            HStack {
                                Spacer()
                                Text(viewModel.errorMessage)
                                    .foregroundColor(Color.red.opacity(0.75))
                                Spacer()
                            }
                        }
                        
                        HStack {
                            Spacer()
                            RoundRectButton(text: "Send", tapHandler: {
                                viewModel.sendReport(fromUser: user, entityID: entityID, entityType: entityType)
                            })
                            .disabled(viewModel.selectedReason.count == 0)
                            .opacity(viewModel.selectedReason.count == 0 ? 0.5 : 1.0)
                            Spacer()
                        }
                    }
                }
                
                Spacer()
            }
            .padding(15)
            .navigationBarTitle("Report")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarHidden(false)
            .onAppear(perform: {
                viewModel.isActive = isActive
            })
        }
    }
}
