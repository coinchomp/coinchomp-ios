//
//  Env.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 12/30/20.
//

import Foundation

class Env : ObservableObject {
    
    var context : String = ""
    var minVersion : String = "0.0.0"
    var isMaintenanceMode : Bool = false
    var linkTemplateVersion : String = ""
    var subscriptionTemplateVersion : String = ""
    var serviceCredentialsVersion : String = ""

    init(withFields fields: [String : Any]){
        if let context = fields["context"] as? String {
            self.context = context
        }
        if let minVersionString = fields["minVersion"] as? String {
            self.minVersion = minVersionString
        }
        if let isMaintenanceMode = fields["maintenanceMode"] as? Bool {
            self.isMaintenanceMode = isMaintenanceMode
        }
        if let linkTemplateVersion = fields["linkTemplateVersion"] as? String {
            self.linkTemplateVersion = linkTemplateVersion
        }
        if let subscriptionTemplateVersion = fields["subscriptionTemplateVersion"] as? String {
            self.subscriptionTemplateVersion = subscriptionTemplateVersion
        }
        if let serviceCredentialsVersion = fields["serviceCredentialsVersion"] as? String {
            self.serviceCredentialsVersion = serviceCredentialsVersion
        }
    }
}
