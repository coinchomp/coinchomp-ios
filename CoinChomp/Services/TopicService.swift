import Foundation
import Firebase

enum TopicServiceError: Error {
    case nonspecificError
}

class TopicService {
    
  static let shared = TopicService()
    
  let db = Firestore.firestore()
    
    lazy var functions = Functions.functions()
    
    func fetchTopics(completion: @escaping ([Topic]?, Error?) -> ()) {
        let docRef = db.collection("topics")
            docRef.getDocuments { (querySnapshot, error) in
            guard let documents = querySnapshot?.documents else {
                print("Error fetching documents: \(error!)")
                completion(nil, TopicServiceError.nonspecificError)
                return
            }
            var topics : [Topic] = []
            for (doc) in documents {
                if let topic = Topic(topicID: doc.documentID, fields: doc.data()){
                    topics.append(topic)
                }
            }
            completion(topics, nil)
        }
    }
    
    func createTopic(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("createTopic").call(data) { (result, topicID) in
            if let result = result,
                     let resultData = result.data as? [String : Any],
                     let topicID = resultData["topicID"] as? String,
                     let didSucceed = resultData["didSucceed"] as? Bool,
                     didSucceed == true {
                    completion(true, topicID)
            } else {
                completion(false, nil)
            }
        }
    }
    
    func deleteTopic(data : [String: Any], completion: @escaping (Bool, String?)->()){
        functions.httpsCallable("deleteTopic").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false, "There was an error. Please try again later.")
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool,
                     didSucceed == true {
                completion(true, nil)
            } else {
                completion(false, "There was an error. Please try again later.")
            }
        }
    }
}
    

