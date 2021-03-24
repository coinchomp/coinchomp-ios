//
//  Date.swift
//  CoinChomp
//
//  Created by Eric Sean Turner on 2/15/21.
//

import Foundation

extension Date {
    
    func hoursElapsed() -> Int? {
        let dateNow = Date()
        let diff = Calendar.current.dateComponents([.hour], from: self, to: dateNow)
        if let hours = diff.hour {
            return hours
        }
        return nil
    }
    
    
    func secondsElapsed() -> Int? {
        let dateNow = Date()
        let diff = Calendar.current.dateComponents([.second], from: self, to: dateNow)
        if let seconds = diff.second {
            return seconds
        }
        return nil
    }
    
    func standardFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        return dateFormatter.string(from: self)
    }
    
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    static func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
}
