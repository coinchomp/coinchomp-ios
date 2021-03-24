import Foundation
import Firebase

enum LinkServiceError: Error {
    case nonspecificError
}

class LinkService {
    
  static let shared = LinkService()
    
    static let templatesKey = "linkTemplatesKey"
    
    let db = Firestore.firestore()
        
    var templates : [LinkTemplate] = []
    
    var templateVersion : String = ""
    
    func hasValidTemplates() -> Bool {
        if self.templates.count > 0 {
            if self.templates.first?.version == self.templateVersion {
                return true
            }
        } else {
            if let linkTemplates = try? UserDefaults.standard.decode([LinkTemplate].self, forKey: Self.templatesKey) {
                if linkTemplates.count > 0 {
                    if linkTemplates.first?.version == self.templateVersion {
                        self.templates = linkTemplates
                        return true
                    }
                }
            }
        }
        return false
    }
    
    func template(forType templateType: String) -> LinkTemplate? {
        if self.templates.count <= 0 {
            if let templates = try? UserDefaults.standard.decode([LinkTemplate].self, forKey: Self.templatesKey) {
                self.templates = templates
            }
        } else if self.templates.first?.version != self.templateVersion {
            self.templates.removeAll()
            UserDefaults.standard.removeObject(forKey: Self.templatesKey)
            print("removed all stored link templates")
            print("environment link templates version: \(self.templateVersion)")
        }
        for template in self.templates {
            if template.type == templateType {
                return template
            }
        }
        return nil
    }
    
    func loadTemplates(templateVersion envLinkTemplateVersion: String){
        self.templateVersion = envLinkTemplateVersion
        var needToFetchRemoteTemplates = true
        if let templates = try? UserDefaults.standard.decode([LinkTemplate].self, forKey: Self.templatesKey) {
            if templates.count > 0 {
                self.templates = templates
                let template = templates[0]
                if template.version == envLinkTemplateVersion {
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
                        print("fetched remote link templates, and stored...")
                    }
                }
            }
        } else {
            print("loaded locally persisted link templates!")
        }
    }
        
    func fetchTemplates(completion: @escaping ([LinkTemplate]?, Error?) -> ()){
        let docRef = db.collection("link_templates")
            docRef.getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil, LinkServiceError.nonspecificError)
            } else {
                var templates : [LinkTemplate] = []
                for document in querySnapshot!.documents {
                    let fields = document.data()
                    if let template = LinkTemplate(withFields: fields){
                        templates.append(template)
                    }
                }
                completion(templates, nil)
            }
        }
    }
    
    func getLinksAwaitingReview(completion: @escaping ([Link]?, Error?) -> ()) {
        let docRef = db.collection("links").whereField("reviewState", isEqualTo: ReviewState.Unreviewed.rawValue)
            docRef.limit(to: 100).getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, LinkServiceError.nonspecificError)
                return
            }
            var links : [Link] = []
            for (doc) in documents {
                let fields = doc.data()
                if var link = Link(withID: doc.documentID, fields: fields) {
                    LinkService.setDates(&link, fields: fields)
                    links.append(link)
                }
            }
            let sorted = links.sorted { (l1, l2) -> Bool in
                return l1.createdAt < l2.createdAt
            }
            links = sorted
            completion(links, nil)
        }
    }
    
    func fetchLink(linkID: String, completion: @escaping (Link?, Error?) -> ()) {
        let docRef = db.collection("links").document(linkID)
        docRef.getDocument { (document, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, LinkServiceError.nonspecificError)
            } else if let document = document,
               document.exists == true,
               let fields = document.data() {
                if var link = Link(withID: document.documentID, fields: fields) {
                    LinkService.setDates(&link, fields: fields)
                    completion(link, nil)
                }else{
                    completion(nil, LinkServiceError.nonspecificError)
                }
            }
        }
    }
    
    func fetchLinks(completion: @escaping ([Link]?, Error?) -> ()) {
        let docRef = db.collection("links").whereField("reviewState", isEqualTo: ReviewState.Approved.rawValue).order(by: "weight", descending: true).limit(to:100)
        docRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, LinkServiceError.nonspecificError)
                return
            }
            var links : [Link] = []
            for (doc) in documents {
                let fields = doc.data()
                if var link = Link(withID: doc.documentID, fields: fields) {
                    LinkService.setDates(&link, fields: fields)
                    links.append(link)
                }
            }
            let sorted = links.sorted { (l1, l2) -> Bool in
                if l1.weight == l2.weight {
                    return l1.createdAt > l2.createdAt
                }
                return l1.weight > l2.weight
            }
            links = sorted
            completion(links, nil)
        }
    }
    
    func fetchFlaggedLinks(completion: @escaping ([Link]?, Error?) -> ()) {
        let docRef = db.collection("links")
            .whereField("reviewState", isEqualTo: ReviewState.Approved.rawValue)
            .whereField("isFlagged", isEqualTo: true)
        docRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, LinkServiceError.nonspecificError)
                return
            }
            var links : [Link] = []
            for (doc) in documents {
                let fields = doc.data()
                if var link = Link(withID: doc.documentID, fields: fields) {
                    LinkService.setDates(&link, fields: fields)
                    links.append(link)
                }
            }
            completion(links, nil)
        }
    }
    
    func fetchClickedLinkIDs(userID: String,
                             completion: @escaping ([String]?, Error?) -> ()) {
        let docRef = db.collection("clicks").whereField("userID", isEqualTo: userID)
        docRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, LinkServiceError.nonspecificError)
                return
            }
            var viewedLinkIDs : [String] = []
            for (doc) in documents {
                let fields = doc.data()
                if let linkID = fields["linkID"] as? String {
                    if !viewedLinkIDs.contains(linkID) {
                        viewedLinkIDs.append(linkID)
                    }
                }
            }
            completion(viewedLinkIDs, nil)
        }
    }
    
    static func setDates(_ link: inout Link, fields: [String:Any]){
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
            link.createdAt = createdAtTimestamp.dateValue()
        }
    }
}
    

