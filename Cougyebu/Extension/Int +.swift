//
//  Int +.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/12.
//

import UIKit

extension Int {
    func makeComma(num: Int) -> String {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let costResult: String = numberFormatter.string(for: num) ?? ""
        return costResult
    }
    
}
