//
//  DatabaseService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/14/21.
//

import Foundation
import Firebase
import FirebaseFunctions

enum DBServiceError : Error {
    case GeneralError
}

class DatabaseService {
    
    static let shared = DatabaseService()

    let db = Firestore.firestore()
    
    lazy var functions = Functions.functions()
    
    func startSubscription(data: [String:Any], completion: @escaping (Bool)->()){
        functions.httpsCallable("startSubscription").call(data) { (result, error) in
          if let error = error as NSError? {
            print(error.localizedDescription)
            completion(false)
          }else if let result = result,
                   let resultData = result.data as? [String : Any]{
            if let didSucceed = resultData["didSucceed"] as? Bool {
                completion(didSucceed)
            }
          }
        }
    }
    
    func awardDailyLoginBonus(user: User){
        guard user.isBanned == false else { return }
        guard user.didLogInToday == false else { return }
        var data : [String : Any] = [:]
        data["userID"] = user.userID
        data["subscriptionProductID"] = user.subscriptionProductID ?? ""
        functions.httpsCallable("awardLoginBonus").call(data) { (result, error) in
          if let error = error as NSError? {
            print(error.localizedDescription)
          }else if let result = result,
                   let resultData = result.data as? [String : Any],
                   let didSucceed = resultData["didSucceed"] as? Bool,
                   didSucceed == true {
                    print("Awarded daily login bonus!!!!!")
          } else {
            print("Failed to award daily login bonus....")
          }
        }
    }
    
    func bulkApproveLinks(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("bulkApproveLinks").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                if didSucceed == true {
                    completion(true, nil)
                }else if let message = resultData["message"] as? String {
                    completion(false, message)
                }else{
                    completion(false, nil)
                }
            }else{
                completion(false, nil)
            }
        }
    }
    
    func approveLink(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("approveLink").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                if didSucceed == true {
                    completion(true, nil)
                }else if let message = resultData["message"] as? String {
                    completion(false, message)
                }else{
                    completion(false, nil)
                }
            }else{
                completion(false, nil)
            }
        }
    }
    
    func bulkRejectLinks(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("bulkRejectLinks").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                if didSucceed == true {
                    completion(true, nil)
                }else if let message = resultData["message"] as? String {
                    completion(false, message)
                }else{
                    completion(false, nil)
                }
            }else{
                completion(false, nil)
            }
        }
    }
    
    func rejectLink(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("rejectLink").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                if didSucceed == true {
                    completion(true, nil)
                }else if let message = resultData["message"] as? String {
                    completion(false, message)
                }else{
                    completion(false, nil)
                }
            }else{
                completion(false, nil)
            }
        }
    }
    
    func recordClick(data : [String: Any]){
        functions.httpsCallable("recordClick").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
            }else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func recordImpression(data : [String: Any]){
        functions.httpsCallable("recordImpression").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
            }else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func bulkRecordHeadlineImpressions(data : [String: Any],
                                       completion: @escaping (Bool)->()){
        functions.httpsCallable("bulkRecordHeadlineImpressions").call(data) {
            (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                completion(didSucceed)
            }else{
                completion(false)
            }
        }
    }
    
    func recordVote(data : [String: Any],
                    completion: @escaping (Bool)->()){
        functions.httpsCallable("recordVote").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                completion(didSucceed)
            }else{
                completion(false)
            }
        }
    }
    
    func createLink(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("createLink").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                if didSucceed == true {
                    completion(true, nil)
                }else if let message = resultData["message"] as? String {
                    completion(false, message)
                }else{
                    completion(false, nil)
                }
            }else{
                completion(false, nil)
            }
        }
    }
    
    func deleteLink(data : [String: Any],
                    completion: @escaping (Bool)->()){
        functions.httpsCallable("deleteLink").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                completion(didSucceed)
            }else{
                completion(false)
            }
        }
    }
    
    func updateLink(data : [String: Any],
                    completion: @escaping (Bool)->()){
        functions.httpsCallable("updateLink").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool{
                completion(didSucceed)
            }else{
                completion(false)
            }
        }
    }
    
}
