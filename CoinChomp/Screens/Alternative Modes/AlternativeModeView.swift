//
//  UpdateRequiredView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/30/20.
//

import SwiftUI

enum Mode {
    case Maintenance
    case UpdateRequired
}

struct AlternativeModeView: View {
    
    let appVersion : String
    let mode : Mode
    
    init(appVersion versionString: String, mode: Mode){
        self.appVersion = versionString
        self.mode = mode
    }
    
    var body: some View {
        VStack {
            
            Spacer()

            if mode == .UpdateRequired {
                
                Text("Update Required!")
                    .font(.largeTitle)
                    .padding(10)
                    .foregroundColor(Color("BWForeground"))
                
                Text("Your installed version of Cryptometheus (v\(self.appVersion)) is outdated. Please download the latest update on the AppStore in order to continue to use the app.")
                    .font(.body)
                    .padding(30)
                    .foregroundColor(Color("BWForeground"))
                
            } else if mode == .Maintenance {
                
                Text("Maintenance...")
                    .font(.largeTitle)
                    .padding(10)
                    .foregroundColor(Color("BWForeground"))
                
                Text("Apologies for the inconvenience! Cryptometheus is currently undergoing scheduled maintenance. Please check back soon.")
                    .font(.body)
                    .padding(30)
                    .foregroundColor(Color("BWForeground"))
            }

            Spacer()
        }
    }
}
