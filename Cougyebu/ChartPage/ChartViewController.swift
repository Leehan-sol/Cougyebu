//
//  ChartViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import UIKit
import Charts
import DGCharts

class ChartViewController: UIViewController {
    private let chartView = ChartView()
    private let players = ["🏡 생활비", "🍚 식비", "🚗 교통비"]
    private let goals = [6, 8, 10]
    
    
    override func loadView() {
        view = chartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeChart(dataPoints: players, values: goals)
    }
    
    func customizeChart(dataPoints: [String], values: [Int]) {
        // 1. ChartDataEntry 세팅, date 배열 순회, 값+이름+데이터
        var dataEntries: [ChartDataEntry] = []
        for i in 0..<dataPoints.count {
            let dataEntry = PieChartDataEntry(value: Double(values[i]), label: String(values[i]), data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        // 2. ChartDataSet 세팅
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = colorsOfCharts(numbersOfColor: dataPoints.count)
        // 레이블 색깔 설정
        pieChartDataSet.valueColors = [.black]
        
        
        // 3. ChartData 설정
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        let format = NumberFormatter()
        format.numberStyle = .none
        let formatter = DefaultValueFormatter(formatter: format)

        // 이 부분에서 값의 포맷을 설정합니다.
        pieChartData.setValueFormatter(formatter)

        // 4. ChareView 설정
        chartView.pieChartView.holeRadiusPercent = 0
        chartView.pieChartView.data = pieChartData
        
        // 4. ChareView 설정
        chartView.pieChartView.holeRadiusPercent = 0
        chartView.pieChartView.data = pieChartData
    }

    
    private func colorsOfCharts(numbersOfColor: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<numbersOfColor {
            let red = Double(arc4random_uniform(256))
            let green = Double(arc4random_uniform(256))
            let blue = Double(arc4random_uniform(256))
            let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
            colors.append(color)
        }
        return colors
    }
    
}
