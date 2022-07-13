//
//  CryptoService.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/4/20.
//

import Foundation
import Firebase
import FirebaseFunctions

enum CryptoServiceError: Error {
    case nonspecificError
}

class CryptoService {
    
    static let shared = CryptoService()
    
    lazy var functions = Functions.functions()
    
    let db = Firestore.firestore()
    
    var cryptosListener : ListenerRegistration?
    
    func cancelListeners(){
        if let listener = cryptosListener {
            listener.remove()
        }
    }
    
    func getCryptosOnRadar(completion: @escaping ([Crypto]?)->()){
        functions.httpsCallable("getCryptosOnRadar").call() { (result, error) in
            if let error = error as NSError? {
                print(error.localizedDescription)
                completion(nil)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool,
                     let cryptoDataItems = resultData["cryptos"] as? [[String : Any]] {
                if didSucceed == true {
                    var cryptos : [Crypto] = []
                    for (cryptoData) in cryptoDataItems {
                        if let documentID = cryptoData["documentID"] as? String,
                           let name = cryptoData["name"] as? String,
                           let symbol = cryptoData["symbol"] as? String,
                           let slug = cryptoData["slug"] as? String,
                           let logoURL = cryptoData["logo"] as? String,
                           let lastQuoteUSD = cryptoData["lastQuoteUSD"] as? Double,
                           let volume24h = cryptoData["volume24h"] as? Double,
                           let marketCap = cryptoData["marketCap"] as? Double {
                            var c1 : Crypto = Crypto(databaseRecordID: documentID,
                                                     name: name,
                                                     symbol: symbol,
                                                     slug: slug,
                                                     logoURL: logoURL,
                                                     volume24h: volume24h,
                                                     marketCap: marketCap,
                                                     lastQuoteUSD: String(lastQuoteUSD),
                                                     lastQuoteAt: Date())
                            if let onRadar = cryptoData["onRadar"] as? Bool,
                               let onRadarHidden = cryptoData["onRadarHidden"] as? Bool {
                                c1.onRadar = onRadar
                                c1.onRadarHidden = onRadarHidden
                            }
                            cryptos.append(c1)
                        }
                    }
                    completion(cryptos)
                }else{
                    print("Unknown error getting radar cryptos")
                    completion(nil)
                }
            }else{
                print("Unknown error getting radar cryptos")
                completion(nil)
            }
        }
    }
    
    func listenForCryptos(completion: @escaping ([Crypto]?, Error?)->()){
        if let listener = self.cryptosListener {
            listener.remove()
            self.cryptosListener = nil
        }
        self.cryptosListener = db.collection("cryptos").addSnapshotListener {
            querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, CryptoServiceError.nonspecificError)
                return
            }
          
            var cryptos : [Crypto] = []
            let now = Date()

            for (doc) in documents {
              if let name = doc["name"] as? String,
                 let symbol = doc["symbol"] as? String,
                 let slug = doc["slug"] as? String,
                 let lastQuoteUSD = doc["lastQuoteUSD"] as? Double,
                 let volume24h = doc["volume24h"] as? Double,
                 let marketCap = doc["marketCap"] as? Double,
                 let logoURL = doc["logo"] as? String,
                 let lastQuoteAt = doc["lastQuoteAt"] as? Timestamp {
                  
                  let quoteDate = lastQuoteAt.dateValue()
                                    
                  /*let diffComponents = Calendar.current.dateComponents([.minute],
                                                                       from: quoteDate,
                                                                       to: now)*/
                  //if let minutes = diffComponents.minute {
                      //let minutesAbsolute = abs(minutes)
                      //if minutesAbsolute <= 8000 {
                          let crypto = Crypto(databaseRecordID: doc.documentID,
                                                   name: name,
                                                   symbol: symbol,
                                                   slug: slug,
                                                   logoURL: logoURL,
                                                   volume24h: volume24h,
                                                   marketCap: marketCap,
                                                   lastQuoteUSD: String(lastQuoteUSD),
                                                   lastQuoteAt: lastQuoteAt.dateValue())
                        cryptos.append(crypto)
                        if(cryptos.count > 100){
                            break
                        }
                      //}
                  //}
               }
            }
            
            let sorted = cryptos.sorted { (crypto1, crypto2) -> Bool in
                return crypto1.marketCap > crypto2.marketCap
            }
            
            completion(Optional.some(sorted), nil)
         }
    }

    func fetchCrypto(cryptoID: String,
                       completion: @escaping (Crypto?, Error?)->()){
        
        let docRef = db.collection("cryptos").document(cryptoID)
        docRef.getDocument { (document, error) in
            
        if let document = document,
            document.exists == true,
            let fields = document.data(),
            let name = fields["name"] as? String,
            let symbol = fields["symbol"] as? String,
            let slug = fields["slug"] as? String,
            let logoURL = fields["logo"] as? String,
            let volume24h = fields["volume24h"] as? Double,
            let marketCap = fields["marketCap"] as? Double,
            let lastQuoteUSD = fields["lastQuoteUSD"] as? Double,
            let lastQuoteTimestamp = fields["lastQuoteAt"] as? Timestamp,
            let isPaid = fields["isPaid"] as? Bool {
            // MARK: -
            // MARK: TODO: implement correct date from lastQuoteDateString
            // MARK: TODO: persist cryptos if possible
            let crypto = Crypto(databaseRecordID: document.documentID,
                                                   name: name,
                                                   symbol: symbol,
                                                   slug: slug,
                                                   logoURL: logoURL,
                                                   volume24h: volume24h,
                                                   marketCap: marketCap,
                                                   lastQuoteUSD: String(lastQuoteUSD),
                                                   lastQuoteAt:
                                                   lastQuoteTimestamp.dateValue())
            completion(crypto, nil)
        } else {
            completion(nil, CryptoServiceError.nonspecificError)
        }
      }
    }
    
}
