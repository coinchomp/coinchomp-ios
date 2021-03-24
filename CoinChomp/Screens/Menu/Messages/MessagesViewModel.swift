//
//  MessagesViewModel.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 1/23/21.
//

import Foundation

class MessagesViewModel : ObservableObject {
    
    let auth = AuthService.shared
    
    @Published var messages : [Message] = []
    
    func startListening(forUserID userID: String){
        MessageService.shared.listenForMessages(userID: userID) { [weak self] (messages, error) in
            if let error = error {
                print(error.localizedDescription)
            } else if let messages = messages {
                self?.didUpdateMessages(messages: messages)
            }
        }
    }
    
    func stopListening(){
        MessageService.shared.cancelListeners()
    }
    
    static func openMessage(message: Message){
        if let messageID = message.databaseRecordID {
            MessageService.shared.setDidOpenMessage(messageID: messageID)
        }
    }
    
    static func deleteMessage(message: Message){
        if let messageID = message.databaseRecordID {
            MessageService.shared.deleteMessage(messageID: messageID)
        }
    }
    
    func didUpdateMessages(messages: [Message]){
        guard let userID = auth.currentUserID else { return }
        self.messages.removeAll()
        for message in messages {
            if message.userID == userID {
                self.messages.append(message)
            }
        }
        self.objectWillChange.send()
    }
}
