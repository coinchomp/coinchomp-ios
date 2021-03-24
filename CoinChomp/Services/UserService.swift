//
//  UserService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 11/27/20.
//

import Foundation
import Firebase

enum UserVoteType : String {
    case Up = "up"
    case Down = "down"
}

enum UserServiceError: Error {
    case nonspecificError
    case establishLocalProfileFailed
}

let tweetNewPredictionsKey = "tweetNewPredictionsKey"
let fieldsNeedingUpdateKey = "fieldsNeedingUpdateKey"

class UserService {
    
  static let shared = UserService()

  let db = Firestore.firestore()
        
  var userListener : ListenerRegistration?
    
    func cancelListeners(){
        if let listener = self.userListener {
            listener.remove()
            self.userListener = nil
        }
    }
    
    func profilesForUsers(withIDs userIDs: [String],
                          completion: @escaping ([User]?, Error?) -> ()){
        let docRef = db.collection("users")
            .whereField(FieldPath.documentID(), in: userIDs)
        docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil, UserServiceError.nonspecificError)
            } else {
                var profiles : [User] = []
                for document in querySnapshot!.documents {
                    let fields = document.data()
                    let userID = document.documentID
                    var profile = User(userID: userID, fields: fields)
                    UserService.setDates(&profile, fields: fields)
                    profiles.append(profile)
                }
                completion(profiles, nil)
            }
        }
    }

    
    func listenToUser(withID userID: String,
                             completion: @escaping (User?, Error?)->()){
        if let listener = self.userListener {
            listener.remove()
            self.userListener = nil
        }
        self.userListener = db.collection("users")
            .document(userID)
            .addSnapshotListener { documentSnapshot, err in
            if let err = err {
                print("Error getting document: \(err)")
                completion(nil, UserServiceError.nonspecificError)
            } else if let document = documentSnapshot {
                if document.exists,
                   let fields = document.data() {
                    
                    var user = User(userID: userID, fields: fields)
                    UserService.setDates(&user, fields: fields)
                    completion(user, nil)
                }
            }
         }
    }
    
    func profileForUser(userID: String,
                        completion: @escaping (User?, Error?) -> ()) {

        let docRef = db.collection("users").document(userID)
        docRef.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, UserServiceError.nonspecificError)
            } else if let document = document,
               document.exists == true,
               let fields = document.data() {
                    var profile = User(userID: userID, fields: fields)
                    UserService.setDates(&profile, fields: fields)
                    completion(profile, nil)
                }
        }
    }
    
    func fetchUserVote(userID: String,
                       entityID: String,
                       completion: @escaping (UserVoteType?, Error?) -> ()) {
        let voteID = entityID + "." + userID
        let docRef = db.collection("user_votes").document(voteID)
        docRef.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, UserServiceError.nonspecificError)
            } else if let document = document,
                   document.exists == true,
                   let fields = document.data(),
                   let voteTypeStr = fields["type"] as? String,
                   let voteType = UserVoteType(rawValue: voteTypeStr) {
                    completion(voteType, nil)
            }else{
                completion(nil, UserServiceError.nonspecificError)
            }
        }
    }
    
    static func wipeUserPreferences(){
        UserDefaults.standard.removeObject(forKey: tweetNewPredictionsKey)
    }
    
    static func persistTweetOnNewPredictionSetting(_ doesTweet: Bool){
        UserDefaults.standard.set(doesTweet, forKey: tweetNewPredictionsKey)
    }
    
    static func fetchDoesTweetOnNewPredictionSetting() -> Bool {
        if let doesTweet = UserDefaults.standard.object(forKey: tweetNewPredictionsKey) as? Bool {
            return doesTweet
        }
        return false
    }
    
    static func setDates(_ user: inout User, fields: [String:Any]){
        // MARK: Smelly code
        /* Ideally I'd like these properties
           to be set within the class constructor but
           referencing Timestamp within class creates
           an undesirable dependency on Firebase.
           Eventually I should find a way to set these dates
           within the class without knowing about
           Firebase's Timestamp type
        */
        if let createdAtTimestamp = fields["createdAt"] as? Timestamp {
            user.createdAt = createdAtTimestamp.dateValue()
        }
        if let lastSeenAtTimestamp = fields["lastSeenAt"] as? Timestamp {
            user.lastSeenAt = lastSeenAtTimestamp.dateValue()
        }
        if let subscriptionExpiresAtTimestamp = fields["subscriptionExpiresAt"] as? Timestamp {
            user.subscriptionExpiresAt = subscriptionExpiresAtTimestamp.dateValue()
        }
        if let lastUpdatedSocialProfileAtTimestamp = fields["lastUpdatedSocialProfileAt"] as? Timestamp {
            user.lastUpdatedSocialProfileAt = lastUpdatedSocialProfileAtTimestamp.dateValue()
        }
    }
}
