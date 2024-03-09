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
    
}
