//
//  AppView.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import SwiftUI

let deepLinkPredictionIDKey = "deepLinkPredictionIDKey"
let deepLinkUserIDKey = "deepLinkUserIDKey"


struct AppView: View {
            
    @ObservedObject var viewModel = AppViewModel()
    
    var body: some View {
        if viewModel.needAppUpdate {
            AlternativeModeView(appVersion: viewModel.appVersion, mode: .UpdateRequired)
        } else if viewModel.isMaintenanceMode {
            AlternativeModeView(appVersion: viewModel.appVersion, mode: .Maintenance)
        } else {
            FrontPageView()
        }
    }
}
