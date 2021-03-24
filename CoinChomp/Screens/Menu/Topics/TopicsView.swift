//
//  TopicsView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 3/15/21.
//

import SwiftUI

class TopicsViewModel : ObservableObject {
    @Published var topics : [Topic] = []
    @Published var showCreateTopic = false
    
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

struct TopicsView: View {
    
    @StateObject var viewModel = TopicsViewModel()
    
    @State var deleteMode = false
    
    var navCreateTopic: NavigationLink<EmptyView, CreateTopicView>? {
        return NavigationLink(
            destination: CreateTopicView(viewIsActive: $viewModel.showCreateTopic),
            isActive: $viewModel.showCreateTopic
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
        
        ZStack {
            
            Color("BWBackground")
            .edgesIgnoringSafeArea(.all)
            
            navCreateTopic
            
            ScrollView(.vertical) {
                
                LazyVStack(alignment: HorizontalAlignment.leading, spacing: 0) {
                    //ForEach(viewModel.links, id: \.self) {
                    ForEach(viewModel.topics.indices, id: \.self) { i in
                        if let topic = viewModel.topics[i] {
                            HStack {
                                Text(topic.name)
                                    .foregroundColor(Color("BWForeground"))
                                Spacer()
                                Button(action: {
                                    // ..
                                }, label: {
                                    Image(systemName: "trash")
                                        .opacity(0.3)
                                })
                            }
                            .padding(.vertical, 15)
                            Divider()
                        }
                    }
                }
                .padding(10)
            }
        }
        .onAppear(perform: {
            viewModel.fetchTopics()
        })
        .navigationBarTitle("Topics")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
                                Button(action: {
                                    viewModel.showCreateTopic = true
                                }, label: {
                                    Text("Add Topic")
                                }))

    }
}
