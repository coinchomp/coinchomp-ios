//
//  TwitterService.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 1/6/21.
//

import Foundation
import CryptoKit
import UIKit

fileprivate let twitterSignature = CharacterSet(arrayLiteral: "0", "1", "2", "3", "4", "5", "6", "7", "8", "9","A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z","-", ".", "_", "~")

class TwitterService {
    
    let hostURL = "https://api.twitter.com/1.1/statuses/update.json"
    
    static let shared = TwitterService()
    
    let auth = AuthService.shared
    
    var headerParams : [TwitterQueryParam] = []
    var queryParams : [TwitterQueryParam] = []
    
    func canTweet() -> Bool {
        if (auth.twitterCredentials()) != nil {
            return true
        }
        return false
    }
    
    func tweet(status:String) {
        
        guard let creds = auth.twitterCredentials() else { return }
        
        print(creds.accessToken)
        print(creds.accessTokenSecret)
        print(creds.consumerKey)
        print(creds.consumerSecret)
                        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.twitter.com"
        urlComponents.path = "/1.1/statuses/update.json"
        urlComponents.queryItems = []
        
        guard let url = urlComponents.url  else { return }
        
        var request = URLRequest(url: url)
        
        let nonce : String = Common.randomString(length: 12)
        let timestamp = String(Int(Date().timeIntervalSince1970))
        
        queryParams.append(TwitterQueryParam(key:"oauth_consumer_key",
                                             value: creds.consumerKey,
                                             isEncoded: true))
        queryParams.append(TwitterQueryParam(key:"oauth_nonce",
                                             value: nonce,
                                             isEncoded: true))
        queryParams.append(TwitterQueryParam(key:"oauth_signature_method",
                                             value: "HMAC-SHA1",
                                             isEncoded: true))
        queryParams.append(TwitterQueryParam(key:"oauth_timestamp",
                                             value: timestamp,
                                             isEncoded: true))
        queryParams.append(TwitterQueryParam(key:"oauth_token",
                                             value: creds.accessToken,
                                             isEncoded: true))
        queryParams.append(TwitterQueryParam(key:"oauth_version",
                                             value: "1.0",
                                             isEncoded: true))
        
        // Copy to header params
        for qp in queryParams {
            headerParams.append(qp)
        }
        
        // Append other query parameters not in header
        queryParams.append(TwitterQueryParam(key:"include_entities",
                                             value: "true",
                                             isEncoded: false))
        queryParams.append(TwitterQueryParam(key:"status",
                                             value: status,
                                             isEncoded: false))
        
        guard let signature = buildSignature(accessTokenSecret: creds.accessTokenSecret, consumerSecret: creds.consumerSecret) else { return }
        
        headerParams.append(TwitterQueryParam(key:"oauth_signature",
                                              value: signature,
                                              isEncoded: true))
        
        guard let authHeader = buildAuthHeader() else { return }

        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        
        let postString = "status=\(status)&include_entities=true"
        request.httpBody = postString.data(using: .utf8)

        let session = URLSession.shared
        let task = session.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let data = data {
                    let str = String(decoding: data, as: UTF8.self)
                    print(str)
                }
                self?.notifyPostedTweet()
            }
        }
        task.resume()
    }
    
    private func notifyPostedTweet(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("postedTweet"), object: nil)
    }
    
    func buildBaseString(host: String, paramString: String) -> String? {
        
        guard let encodedParamString = Self.encode(paramString),
              let encodedHost = Self.encode(host) else { return nil }
        
        return "POST&" + encodedHost + "&" + encodedParamString
    }
    
    func buildAuthHeader() -> String? {
        let sorted = headerParams.sorted { $0.key < $1.key }
        headerParams = sorted
        var header = "OAuth "
        for param in headerParams {
            guard let encodedKey = param.getKey(),
                  let encodedValue = param.getValue() else { return nil }
            header+=encodedKey+"=\""+encodedValue+"\", "
        }
        return String(header.dropLast(2))
    }
    
    func navigateToScreenName(screenName: String){
        let appURLString = "twitter://user?screen_name=" + screenName
        let webURLString = "https://twitter.com/" + screenName
        if let appURL = URL(string: appURLString),
           let webURL = URL(string: webURLString) {
            if UIApplication.shared.canOpenURL(appURL) {
                UIApplication.shared.open(appURL)
            } else {
                UIApplication.shared.open(webURL)
            }
        }
    }
    
    func buildSignature(accessTokenSecret: String, consumerSecret: String) -> String? {
                
        let sorted = queryParams.sorted { $0.key < $1.key }
        queryParams = sorted
                
        var paramString = ""
        for param in queryParams {
            guard let encodedKey = param.getKey(),
                  let encodedValue = param.getValue() else { return nil }
            paramString+=encodedKey+"="+encodedValue+"&"
        }
        paramString = String(paramString.dropLast())
        
        guard let baseString = buildBaseString(host: hostURL,
                                              paramString: paramString) else { return nil }
        
        guard let encodedConsumerSecret = Self.encode(consumerSecret),
              let encodedTokenSecret = Self.encode(accessTokenSecret) else { return nil }
        
        let signingKey = encodedConsumerSecret + "&" + encodedTokenSecret
        
        return baseString.hmac(key: signingKey)
    }
    
    static func encode(_ string: String) -> String? {
        if let encoded = string.addingPercentEncoding(withAllowedCharacters: twitterSignature) {
            return encoded
        }
        return nil
    }
    
    struct TwitterQueryParam {
        let key : String
        let value : String
        let isEncoded : Bool
        func getKey() -> String? {
            if isEncoded == false {
                return key
            }
            guard let k = key.addingPercentEncoding(withAllowedCharacters: twitterSignature) else { return nil }
            return k
        }
        func getValue() -> String? {
            if isEncoded == false {
                return value
            }
            guard let v = value.addingPercentEncoding(withAllowedCharacters: twitterSignature) else { return nil }
            return v
        }
    }
}
