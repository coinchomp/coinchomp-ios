import Foundation
import Firebase

enum FlagServiceError: Error {
    case nonspecificError
}

class FlagService {
    
  static let shared = FlagService()
    
  let db = Firestore.firestore()
    
    lazy var functions = Functions.functions()
    
    func flagContent(data : [String: Any], completion: @escaping (Bool)->()){
        functions.httpsCallable("flagContent").call(data) { (result, error) in
            if let error = error as NSError? {
              print(error.localizedDescription)
                completion(false)
            }else if let result = result,
                     let resultData = result.data as? [String : Any],
                     let didSucceed = resultData["didSucceed"] as? Bool,
                     didSucceed == true {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
    

