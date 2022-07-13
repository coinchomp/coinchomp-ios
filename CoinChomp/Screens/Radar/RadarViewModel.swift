//
//  CryptoViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import Foundation
import Combine
import Firebase

class RadarViewModel: ObservableObject {
    
    let auth = AuthService.shared
    
    let dbService = DatabaseService.shared
    let cService = CryptoService.shared
            
    @Published var cryptos : [Crypto] = []
    @Published var selectedCrypto : Crypto? = nil
    @Published var isActive = false
    @Published var showLogInView = false
    
    init(){
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(respondAuthStateChange),
                       name: Notification.Name("authStateDidChange"),
                       object: nil)
    }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            if let userID = self.auth.currentUserID {
                self.showLogInView = false
            }
            self.objectWillChange.send()
        }
    }
    
    func getCryptosOnRadar(){
        CryptoService.shared.getCryptosOnRadar() {
            [weak self] (cryptos) in
            if let cryptos = cryptos {
                self?.didUpdateCryptos(cryptos: cryptos)
            } else {
                print("no radar cryptos...")
            }
        }
    }
    
    func didUpdateCryptos(cryptos: [Crypto]){
        //guard let user = auth.currentUser else { return }
        var userIsPaid = false
        if let user = auth.currentUser {
            if user.isPaid {
                userIsPaid = true
            }
        }
        self.cryptos.removeAll()
        // 1. Add all available currencies for user
        for crypto in cryptos {
            self.cryptos.append(crypto)
        }
        self.objectWillChange.send()
    }
}

