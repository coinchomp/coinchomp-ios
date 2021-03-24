//
//  MessageService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/23/21.
//

import Foundation
import Firebase

enum MessageServiceError: Error {
    case nonspecificError
}

class MessageService {
    
  static let shared = MessageService()
    
  let db = Firestore.firestore()
    
  var messagesListener : ListenerRegistration?
    
    func cancelListeners(){
        if let listener = messagesListener {
            listener.remove()
        }
    }

    func listenForMessages(userID: String,
                           completion: @escaping ([Message]?, Error?)->()){
        if let listener = self.messagesListener {
            listener.remove()
            self.messagesListener = nil
        }
        self.messagesListener = db.collection("messages")
            .whereField("userID", isEqualTo: userID)
            .addSnapshotListener {
            querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, MessageServiceError.nonspecificError)
                return
            }
            var messages : [Message] = []
            for (doc) in documents {
                let fields = doc.data()
                if var message = Message(documentID: doc.documentID, withFields: fields){
                    MessageService.setDates(&message, fields: fields)
                    messages.append(message)
                }
            }
            let sorted = messages.sorted { (m1, m2) -> Bool in
                return m1.createdAt > m2.createdAt
            }
            completion(Optional.some(sorted), nil)
        }
     }
    
    func setDidOpenMessage(messageID: String){
        let messageRef = db.collection("messages").document(messageID)
        messageRef.updateData([
            "didOpen": true
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
            }
        }
    }
    
    func deleteMessage(messageID: String){
        let messageRef = db.collection("messages").document(messageID)
        messageRef.delete() { err in
            if let err = err {
                print("Error deleting document: \(err)")
            } else {
                print("Document successfully deleted")
            }
        }
    }
        
    static func setDates(_ message: inout Message, fields: [String:Any]){
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
            message.createdAt = createdAtTimestamp.dateValue()
        }
    }
}
