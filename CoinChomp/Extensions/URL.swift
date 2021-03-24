//
//  URL.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import Foundation

extension URL {
    
    var isDeeplink: Bool {
        return scheme == "CoinChomp" // matches CoinChomp://<rest-of-the-url>
    }
    
    func isValid() -> Bool {
        let baseURL = EnvService.shared.getWebBaseURL()
        var envHost = baseURL.replacingOccurrences(of: "https://", with: "")
        envHost = baseURL.replacingOccurrences(of: "http://", with: "")
        return (isDeeplink || host == envHost) && (absoluteString.contains("user") || absoluteString.contains("prediction"))
    }
}
