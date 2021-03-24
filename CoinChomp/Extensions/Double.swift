//
//  Double.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import Foundation

extension Double {
    var formatChomp: String {
        return truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(format: "%.0f", self)
    }
}
