//
//  AppViewModel.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import Foundation
import UIKit

class AppViewModel : ObservableObject {
        
    @Published var appVersion : String = "0.0.0"
    @Published var minVersion : String = "0.0.0"
    @Published var needAppUpdate : Bool = false
    @Published var isMaintenanceMode : Bool = false
        
    init(){
        
        if let versionString = UIApplication.appVersion {
            self.appVersion = versionString
        }
        
        EnvService.shared.listenToEnv(){
            [self] (env, err) in
            if let err = err {
                print(err.localizedDescription)
            }else if let env = env {
                DispatchQueue.main.async {
                    self.didUpdateEnv(env: env)
                    self.objectWillChange.send()
                }
            }
        }
    }
    
    func didUpdateEnv(env: Env){
        self.minVersion = env.minVersion
        if self.appVersion.versionCompare(self.minVersion) == ComparisonResult.orderedAscending {
            self.needAppUpdate = true
        }
        if env.isMaintenanceMode {
            self.isMaintenanceMode = true
        }
        ServiceCredentialsService.shared.loadCredentials(credentialsVersion: env.serviceCredentialsVersion)
        SubscriptionService.shared.loadTemplates(templateVersion: env.subscriptionTemplateVersion)
        LinkService.shared.loadTemplates(templateVersion: env.linkTemplateVersion)
    }
}
