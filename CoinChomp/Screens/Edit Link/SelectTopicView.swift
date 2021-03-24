//
//  TopicsView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/15/21.
//

import SwiftUI

class SelectTopicViewModel : ObservableObject {
    
    @Published var topics : [Topic] = []
    @Published var selectedTopicID : String = ""

    func fetchTopics() {
        TopicService.shared.fetchTopics { [weak self] (topics, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let topics = topics {
                self?.topics = topics
            }
        }
    }
}

struct SelectTopicView: View {
    
    @StateObject var viewModel = SelectTopicViewModel()
    
    @State var hasTopic : Bool = false

    @State var initialTopicID = ""
    
    let link : Link
        
    let isActive : Binding<Bool>?
    
    init(withLink link: Link, isActive: Binding<Bool>){
        self.link = link
        self.isActive = isActive
        self.initialTopicID = link.topicID
    }
    
    var body: some View {
        
        ZStack {
            
            Color("BWBackground")
            .edgesIgnoringSafeArea(.all)
                        
            ScrollView(.vertical) {
                
                LazyVStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                    ForEach(viewModel.topics.indices, id: \.self) { i in
                        if let topic = viewModel.topics[i] {
                            HStack {
                                
                                Button(action: {
                                    if viewModel.selectedTopicID == topic.topicID {
                                        viewModel.selectedTopicID = ""
                                        link.topicID = ""
                                    }else {
                                        viewModel.selectedTopicID = topic.topicID
                                        link.topicID = topic.topicID
                                    }
                                }, label: {
                                    Image(systemName: viewModel.selectedTopicID == topic.topicID ? "checkmark.square" : "square")
                                })
                                
                                Text(topic.name)
                                    .foregroundColor(Color("BWForeground"))
                                
                                Spacer()
                                                                
                                
                            }
                            .padding(.vertical, 15)
                            
                            Divider()
                        }
                    }
                }
                .padding(15)
            }
        }
        .onAppear(perform: {
            viewModel.fetchTopics()
            viewModel.selectedTopicID = link.topicID
        })
        .navigationBarTitle("Topics")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    isActive?.wrappedValue = false
                                }, label: {
                                    Text("Cancel")
                                }))

    }
}
