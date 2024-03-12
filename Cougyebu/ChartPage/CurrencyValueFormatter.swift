//
//  CurrencyValueFormatter.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/12.
//

import Foundation
import DGCharts

class CurrencyValueFormatter: NSObject, ValueFormatter {
    private let suffix: String
    
    init(suffix: String) {
        self.suffix = suffix
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry?, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return "\(numberFormatter.string(from: NSNumber(value: value)) ?? "")\(suffix)"
    }
}



