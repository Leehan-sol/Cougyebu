//
//  CustomValueFormatter.swift
//  Cougyebu
//
//  Created by hansol on 2024/09/23.
//

import Foundation
import Charts
import DGCharts

class CustomValueFormatter: ValueFormatter {
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        if let sum = entry.data as? Int {
            return "\(sum.makeComma(num: sum))원"
        } else {
            return "\(Int(value))원"
        }
    }
}
