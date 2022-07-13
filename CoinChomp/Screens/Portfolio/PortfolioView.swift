//
//  CryptoPickerView.swift
//  Cryptometheus
//
//  Created by Eric Sean Turner on 12/1/20.
//

import SwiftUI

struct PieSliceData {
    var startAngle: Angle
    var endAngle: Angle
    var color: Color
    var text: String
}

struct PortfolioView: View {
    
    @StateObject var viewModel = PortfolioViewModel()
    
    var pieSliceData: PieSliceData
    
    var midRadians: Double {
        return Double.pi / 2.0 - (pieSliceData.startAngle + pieSliceData.endAngle).radians / 2.0
    }
    
    func selectCrypto(crypto: Crypto){
        if viewModel.auth.currentUser == nil {
            viewModel.showLogInView = true
        }else{
            if crypto.isEnabled {
                viewModel.selectedCrypto = crypto
                viewModel.isActive = true
            }
        }
    }
        
    var body: some View {
        NavigationView{
            ZStack {
                
                VStack(alignment: HorizontalAlignment.center,
                       spacing: 10) {

                    Text("Select a Crypto (\(String(viewModel.cryptos.count))):")
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))

                    GeometryReader { geometry in
                                ZStack {
                                    Path { path in
                                        let width: CGFloat = min(geometry.size.width, geometry.size.height)
                                        let height = width
                                        
                                        let center = CGPoint(x: width * 0.5, y: height * 0.5)
                                        
                                        path.move(to: center)
                                        
                                        path.addArc(
                                            center: center,
                                            radius: width * 0.5,
                                            startAngle: Angle(degrees: -90.0) + pieSliceData.startAngle,
                                            endAngle: Angle(degrees: -90.0) + pieSliceData.endAngle,
                                            clockwise: false)
                                        
                                    }
                                    .fill(pieSliceData.color)
                                    
                                    Text(verbatim: pieSliceData.text)
                                        .position(
                                            x: geometry.size.width * 0.5 * CGFloat(1.0 + 0.78 * cos(self.midRadians)),
                                            y: geometry.size.height * 0.5 * CGFloat(1.0 - 0.78 * sin(self.midRadians))
                                        )
                                        .foregroundColor(Color.white)
                                }
                            }
                            .aspectRatio(1, contentMode: .fit)
                    
                    
                }
                .background(Color.gray.opacity(0.10))

            }
            .padding(0)
            .navigationBarTitle("Prediction Step 1/5")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear(perform: {
                if let userID = viewModel.auth.currentUserID {
                    viewModel.startListening(userID: userID)
                } else {
                    viewModel.startListening(userID: nil)
                }
            })
            .onDisappear(perform: {
                viewModel.stopListening()
            })
            .sheet(isPresented: $viewModel.showLogInView) {
                // blah
            } content: {
                LoginView(withMessage: nil)
            }
        }
    }
}
