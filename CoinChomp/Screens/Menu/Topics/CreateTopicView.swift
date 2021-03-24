//
//  CreateTopicView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/15/21.
//

import SwiftUI

class CreateTopicViewModel : ObservableObject {
    
    @Published var topicName : String = ""
    @Published var isBusy : Bool = false
    
    var viewIsActive : Binding<Bool>?
    
    func createTopic(){
        guard let user = AuthService.shared.currentUser else { return }
        isBusy = true
        var data : [String:String] = [:]
        data["name"] = topicName
        data["userID"] = user.userID
        TopicService.shared.createTopic(data: data, completion: {
            [weak self] (didSucceed, topicID) in
            self?.isBusy = false
            if didSucceed == true {
                self?.viewIsActive?.wrappedValue = false
            }
        })
    }
}

struct CreateTopicView: View {
    
    @StateObject var viewModel = CreateTopicViewModel()

    var viewIsActive : Binding<Bool>
    
    var body: some View {
        
        ZStack {
            
            Color("BWBackground")
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                
                TextField("Enter Topic Name", text: $viewModel.topicName, onEditingChanged: { (editingChanged) in
                            if editingChanged {
                                print("TextField focused")
                            } else {
                                print("TextField focus removed")
                            }
                        })
                .keyboardType(.alphabet)
                .foregroundColor(Color("BWForeground"))
                .padding(.horizontal, 20.0)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                if viewModel.isBusy {
                    ProgressView()
                } else {
                    RoundRectButton(text: "Save", tapHandler: {
                        viewModel.createTopic()
                    })
                }
                
                
                Spacer()
            }
            .padding(15)
            .onAppear(perform: {
                viewModel.viewIsActive = viewIsActive
            })
        }
        .navigationBarTitle("Create Topic")
        .navigationBarTitleDisplayMode(.inline)
    }
}

