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
            AppTabView()
        }
    }
    
    struct AppTabView : View {
        
        @State var selectedTab = 0
                    
        var body : some View {
            
            TabView(selection: $selectedTab) {
                
                WalletView()
                    .tabItem {
                        Image(systemName: "wallet")
                        Text("Wallet")
                    }
                
               FrontPageView()
                .tabItem {
                    Image(systemName: "flame")
                    Text("Home")
                }
                .tag(0)
                
//                PortfolioView(pieSliceData: PieSliceData(
//                                startAngle: Angle(degrees: 0.0),
//                                endAngle: Angle(degrees: 220.0),
//                                color: Color.black,
//                                text: "Anything"))
//                    .tabItem {
//                        Image(systemName:"chart.pie.fill")
//                        Text("Portfolio")
//                    }
//                    .tag(1)

                MenuView()
                    .tabItem {
                        Image(systemName:"list.dash")
                        Text("Menu")
                    }
                    .tag(2)
                
            }.onOpenURL { url in
                if url.isValid() {
                    if url.absoluteString.contains("prediction"){
                        let predictionID = url.lastPathComponent
                        UserDefaults.standard.set(predictionID, forKey: deepLinkPredictionIDKey)
                        selectedTab = 0
                        notifyNeedDeepLink()
                    } else if url.absoluteString.contains("user"){
                        let userID = url.lastPathComponent
                        UserDefaults.standard.set(userID, forKey: deepLinkUserIDKey)
                        selectedTab = 0
                        notifyNeedDeepLink()
                    }
                }
            }
        }
        
        private func notifyNeedDeepLink(){
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("needDeepLinking"), object: nil)
        }
    }
}
