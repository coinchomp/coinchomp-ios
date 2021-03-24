//
//  EnvService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 12/8/20.
//

import Foundation
import Firebase

enum EnvServiceError : Error {
    case NonspecificError
}

struct EnvPreferences: Codable {
    var webBaseURL:String
}

class EnvService {
        
    static let shared = EnvService()
    
    let db = Firestore.firestore()
    
    var envListener : ListenerRegistration?
    
    func cancelListeners(){
        if let listener = envListener {
            listener.remove()
        }
    }
    
    func getContextString() -> String {
        var remoteSummary = "?"
        let defaults = UserDefaults.standard
        if let remoteContext = defaults.string(forKey: "envRemoteContext") {
            if remoteContext.count > 0 {
                remoteSummary = remoteContext[0]
            }
        }
        return remoteSummary
    }
    
    func listenToEnv(completion: @escaping (Env?, Error?)->()){
        self.envListener = db.collection("environment")
            .document("environment")
            .addSnapshotListener { documentSnapshot, err in
            if let err = err {
                print("Error getting environment: \(err)")
                completion(nil, EnvServiceError.NonspecificError)
                } else if let document = documentSnapshot {
                    if document.exists,
                    let fields = document.data() {
                        let env = Env(withFields: fields)
                        let defaults = UserDefaults.standard
                        defaults.setValue(env.context, forKey: "envRemoteContext")
                        completion(env, nil)
                }
            }
        }
    }
    
    func getWebBaseURL() -> String {
        if  let path        = Bundle.main.path(forResource: "EnvPreferences", ofType: "plist"),
            let xml         = FileManager.default.contents(atPath: path),
            let preferences = try? PropertyListDecoder().decode(EnvPreferences.self, from: xml)
        {
            return preferences.webBaseURL
        }
        return "https://CoinChomp.com"
    }
}
