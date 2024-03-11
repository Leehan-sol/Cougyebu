//
//  ChartView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import UIKit
import Charts
import DGCharts

class ChartView: UIView {
    
    let pieChartView: PieChartView = {
        let chartView = PieChartView()
        return chartView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(pieChartView)
        
        pieChartView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
    }
    
    
    
}
