//
//  CoinChompApp.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import SwiftUI
import Firebase

@main
struct CoinChompApp: App {
    
    @Environment(\.scenePhase) var scenePhase

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
        
    init(){
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    private func notifyNeedDeepLink(){
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("needDeepLinking"), object: nil)
    }
        
    var body: some Scene {
        
        WindowGroup {
            AppView()
            .onOpenURL { url in
                if url.isValid() {
                    if url.absoluteString.contains("prediction"){
                        let predictionID = url.lastPathComponent
                        UserDefaults.standard.set(predictionID, forKey: deepLinkPredictionIDKey)
                        notifyNeedDeepLink()
                    } else if url.absoluteString.contains("user"){
                        let userID = url.lastPathComponent
                        UserDefaults.standard.set(userID, forKey: deepLinkUserIDKey)
                        notifyNeedDeepLink()
                    }
                }
            }
        }
        .onChange(of: scenePhase) { newScenePhase in
            switch newScenePhase {
            case .active:
                AuthService.shared.startListening()
              print("App scene phase is now: active")
            case .inactive:
              print("App scene phase is now: inactive")
            case .background:
                AuthService.shared.stopListening()
                print("App scene phase is now: background")
            @unknown default:
              print("Oh - interesting: I received an unexpected new value.")
            }
          }
    }
}

