//
//  ServiceCredentialsService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/6/21.
//

import Foundation
import Firebase

enum ServiceCredentialsServiceError : Error {
    case NonspecificError
}

class ServiceCredentialsService {
    
    static let credentialsKey = "serviceCredentialsVersion"
    
    static let shared = ServiceCredentialsService()
    
    let auth = AuthService.shared
    
    let db = Firestore.firestore()
                
    func loadCredentials(credentialsVersion versionInEnv: String){
        if let credsVersion = UserDefaults.standard.object(forKey: Self.credentialsKey) as? String,
           credsVersion != versionInEnv {
            print("valid service credentials available locally (no need to load)!")
        } else {
            self.fetchCredentials{ [weak self] (credentials, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let credentials = credentials {
                    for (k,v) in credentials {
                        if k == "version" {
                            print(k)
                            UserDefaults.standard.setValue(v, forKey: Self.credentialsKey)
                        }else{
                            self?.auth.storeSecureCredential(withKey: k, value: v)
                        }
                    }
                }
            }
        }
    }
        
    func fetchCredentials(completion: @escaping ([String:String]?, Error?) -> ()){
        let docRef = db.collection("service_credentials").document("service_credentials")
            docRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, ServiceCredentialsServiceError.NonspecificError)
            } else if let document = document, document.exists == true,
                      let credentials = document.data() as? [String:String] {
                completion(credentials, nil)
            }
        }
    }

}
