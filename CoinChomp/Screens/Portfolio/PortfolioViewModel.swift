//
//  CryptoViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import Foundation
import Combine
import Firebase

class PortfolioViewModel: ObservableObject {
    
    let auth = AuthService.shared
    
    let dbService = DatabaseService.shared
    let cService = CryptoService.shared
        
    var blockedCryptoIDs : [String] = []
    
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
        nc.addObserver(self,
                       selector: #selector(respondNavigatedAwayFromPredictionDetailView),
                       name: Notification.Name("navigatedAwayFromPredictionDetailView"),
                       object: nil)
    }
    
    @objc private func respondAuthStateChange(){
        DispatchQueue.main.async {
            if let userID = self.auth.currentUserID {
                self.showLogInView = false
                self.stopListening()
                self.startListening(userID: userID)
            } else {
                self.blockedCryptoIDs.removeAll()
            }
            self.objectWillChange.send()
        }
    }
    
    @objc private func respondNavigatedAwayFromPredictionDetailView(){
        self.isActive = false
        self.selectedCrypto = nil
    }
    
    func startListening(userID: String?){
        cService.listenForCryptos(completion: { [weak self] (cryptos, error) in
            if let error = error {
                print(error)
            } else if let cryptos = cryptos {
                DispatchQueue.main.async {
                    self?.didUpdateCryptos(cryptos: cryptos)
                }
            }
        })
    }
    
    func stopListening(){
        cService.cancelListeners()
    }
    
    func blockedCryptoIDs(usedCryptos: [UsedCrypto]) -> [String] {
        var blockedCryptoIDs : [String] = []
        for usedCrypto in usedCryptos {
            if blockedCryptoIDs.contains(usedCrypto.cryptoID) == false {
                blockedCryptoIDs.append(usedCrypto.cryptoID)
            }
        }
        return blockedCryptoIDs
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
        disableBlockedCurrencies()
        self.objectWillChange.send()
    }
    
    func didUpdateUsedCryptos(usedCryptos: [UsedCrypto]){
        self.blockedCryptoIDs = blockedCryptoIDs(usedCryptos: usedCryptos)
        disableBlockedCurrencies()
        self.objectWillChange.send()
    }
    
    private func disableBlockedCurrencies(){
        // 1. Disable blocked currencies for user
        for crypto in self.cryptos {
            crypto.isEnabled = true
            for blockedCryptoID in self.blockedCryptoIDs {
                if crypto.databaseRecordID == blockedCryptoID {
                    crypto.isEnabled = false
                    break
                }
            }
        }
    }
}

