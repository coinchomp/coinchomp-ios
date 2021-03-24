//
//  BulkSelectLinksView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/20/21.
//

import SwiftUI

struct BulkSelectLinksView: View {
    
    @StateObject var viewModel = BulkSelectLinksViewModel()
        
    var navManualReview: NavigationLink<EmptyView, ManualReviewView>? {
        guard viewModel.showingManualReview == true else { return nil }
        return NavigationLink(
            destination: ManualReviewView(links: viewModel.links,
                                         isActive: $viewModel.showingManualReview),
            isActive: $viewModel.showingManualReview
        ) {
            EmptyView()
        }
    }
    
    var body: some View {
                    
        ZStack {
            
            navManualReview
            
            VStack {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    if viewModel.links.count == 0 {
                        Text("Nothing to review")
                            .foregroundColor(Color("BWForeground"))
                            .padding(.vertical, 30)
                    }
                    
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach((viewModel.links), id: \.self) {
                            if let link = $0,
                               let reviewState = viewModel.reviewStates[link.linkID] {
                                BulkSelectLinkCell(link: link,
                                                   reviewState: reviewState,
                                                   action: {
                                    viewModel.tappedLink(link)
                                })
                            }
                        }
                    }
                }
                .padding(.horizontal, 15)
                
                if viewModel.links.count > 0 {
                    Button(action: {
                        viewModel.tappedProcessLinks()
                    }, label: {
                        Text(viewModel.isBusy ? "Processing..." : viewModel.buttonTitle)
                            .font(.system(size:16))
                            .frame(minWidth: UIScreen.main.bounds.size.width * 0.75,
                                   maxWidth: .infinity,
                                   minHeight: 0,
                                   maxHeight: 35,
                                   alignment: .center)
                            .padding(10)
                            .background(Color("BWBackground").opacity(0.25))
                            .foregroundColor(Color("CoinChompSecondary"))
                    }).disabled(viewModel.isBusy)
                }
            }
        }
        .navigationBarTitle("Bulk Select")
        .onAppear(perform: {
            viewModel.installed = true
            viewModel.prepareData()
        })
    }
}
