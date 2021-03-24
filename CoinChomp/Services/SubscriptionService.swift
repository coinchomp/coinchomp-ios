//
//  SubscriptionService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/31/21.
//

import Foundation
import Firebase

enum SubscriptionServiceError : Error {
    case NonspecificError
}

class SubscriptionService {
    
    static let shared = SubscriptionService()
    
    static let templatesKey = "subscriptionTemplatesKey"
    
    let db = Firestore.firestore()
        
    var templates : [SubscriptionTemplate] = []
    
    var templateVersion : String = ""
    
    func hasValidTemplates() -> Bool {
        if self.templates.count > 0 {
            if self.templates.first?.version == self.templateVersion {
                return true
            }
        } else {
            if let actionTemplates = try? UserDefaults.standard.decode([SubscriptionTemplate].self, forKey: Self.templatesKey) {
                if actionTemplates.count > 0 {
                    if actionTemplates.first?.version == self.templateVersion {
                        self.templates = actionTemplates
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func template(forProductID productID: String) -> SubscriptionTemplate? {
        if self.templates.count <= 0 {
            if let templates = try? UserDefaults.standard.decode([SubscriptionTemplate].self, forKey: Self.templatesKey) {
                self.templates = templates
            }
        } else if self.templates.first?.version != self.templateVersion {
            self.templates.removeAll()
            UserDefaults.standard.removeObject(forKey: Self.templatesKey)
            print("removed all stored subscription templates")
            print("environment subscription templates version: \(self.templateVersion)")
        }
        for template in self.templates {
            if template.productID == productID {
                return template
            }
        }
        return nil
    }
    
    func loadTemplates(templateVersion envSubscriptionTemplateVersion: String){
        self.templateVersion = envSubscriptionTemplateVersion
        var needToFetchRemoteTemplates = true
        if let templates = try? UserDefaults.standard.decode([SubscriptionTemplate].self, forKey: Self.templatesKey) {
            if templates.count > 0 {
                self.templates = templates
                let template = templates[0]
                if template.version == envSubscriptionTemplateVersion {
                    needToFetchRemoteTemplates = false
                }
            }
        }
        if needToFetchRemoteTemplates {
            self.fetchTemplates{ [weak self] (templates, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else if let templates = templates {
                    self?.templates = templates
                    if (try? UserDefaults.standard.encode(templates, forKey: Self.templatesKey)) != nil {
                        print("fetched remote subscription templates, and stored...")
                    }
                }
            }
        } else {
            print("loaded locally persisted subscription templates!")
        }
    }
        
    func fetchTemplates(completion: @escaping ([SubscriptionTemplate]?, Error?) -> ()){
        let docRef = db.collection("subscription_templates")
            docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil, SubscriptionServiceError.NonspecificError)
            } else {
                var templates : [SubscriptionTemplate] = []
                for document in querySnapshot!.documents {
                    let fields = document.data()
                    if let template = SubscriptionTemplate(withFields: fields){
                        templates.append(template)
                    }
                }
                let sorted = templates.sorted { (template1, template2) -> Bool in
                    return template1.sortOrder < template2.sortOrder
                }
                completion(sorted, nil)
            }
        }
    }
    
    func fetchReceipts(forUser user: User,
                       completion: @escaping ([Receipt]?, Error?) -> ()){
        let docRef = db.collection("user_receipts").whereField("userID", isEqualTo: user.userID)
            docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil, SubscriptionServiceError.NonspecificError)
            } else {
                var receipts : [Receipt] = []
                for document in querySnapshot!.documents {
                    let fields = document.data()
                    if var receipt = Receipt(withID: document.documentID, fields : fields){
                        SubscriptionService.setDates(&receipt, fields: fields)
                        receipts.append(receipt)
                    }
                }
                let sorted = receipts.sorted { (receipt1, receipt2) -> Bool in
                    return receipt1.createdAt > receipt2.createdAt
                }
                completion(sorted, nil)
            }
        }
    }
    
    static func setDates(_ receipt: inout Receipt, fields: [String:Any]){
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
            receipt.createdAt = createdAtTimestamp.dateValue()
        }
    }
}
