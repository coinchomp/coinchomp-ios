//
//  BulkSelectLinkCell.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/20/21.
//

import SwiftUI

struct BulkSelectLinkCell: View {
    
    let link : Link
    let reviewState : IntermediateReviewState
    let action : ()->()
    
    var body: some View {
        HStack {
            
            Button(action: {
                action()
            }, label: {
                HStack {
                    if reviewState == IntermediateReviewState.Approve {
                        Image(systemName: "checkmark.square")
                    } else if reviewState == IntermediateReviewState.ManuallyReview {
                        Image(systemName: "eyeglasses")
                    } else {
                        Image(systemName: "square")
                    }
                }
            })
            
            VStack(alignment: .leading, spacing: 2) {
                Text(link.title)
                    .font(.system(size:14))
                    .foregroundColor(Color("BWForeground"))
                Text(link.destination)
                    .font(.system(size:10))
                    .foregroundColor(Color("BWForeground").opacity(0.5))
            }
            
            if link.type == LinkType.Web {
                Spacer()
                Button(action: {
                    UIApplication.shared.open(URL(string: link.destination)!)
                }, label: {
                    Image(systemName: "link")
                })
            }
            
        } // HStack
        .background(link.isFlagged ? Color.red.opacity(0.5) : Color("BWBackground"))
        .opacity(reviewState != IntermediateReviewState.Reject ? 1.0 : 0.45)
        .padding(.bottom, 5)
        .padding(.top, 5)
    }
}
