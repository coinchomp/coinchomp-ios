//
//  ReceiptsViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 2/1/21.
//

import Foundation

class ReceiptsViewModel : ObservableObject {
    
    @Published var receipts : [Receipt] = []
    
    init(){}
    
    private func didUpdateReceipts(receipts: [Receipt]){
        self.receipts = receipts
        self.objectWillChange.send()
    }
    
    func fetchReceipts(forUser user: User){
        SubscriptionService.shared.fetchReceipts(forUser: user) {
            [weak self] (receipts, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let receipts = receipts {
                self?.didUpdateReceipts(receipts: receipts)
            }
        }
    }
}
