//
//  Date +.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation

extension Date {
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components)!
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        var components = DateComponents()
        components.month = 1
        components.day = -1
        return calendar.date(byAdding: components, to: self.startOfMonth())!
    }
    
//    func getAllDatesInMonth() -> [Date] {
//        let calendar = Calendar.current
//        let range = calendar.range(of: .day, in: .month, for: self)!
//        let days = range.map { (day) -> Date in
//            return calendar.date(byAdding: .day, value: day - 1, to: self.startOfMonth())!
//        }
//        return days
//    }
//    
    func getAllDatesInMonthAsString() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        let range = Calendar.current.range(of: .day, in: .month, for: startOfMonth)!
        let days = range.map { (day) -> String in
            let date = Calendar.current.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            return dateFormatter.string(from: date)
        }
        return days
    }
}
