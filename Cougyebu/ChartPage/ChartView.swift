//
//  ChartView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import UIKit
import Charts
import DGCharts
import FSCalendar

class ChartView: UIView {
    
    let startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("시작날짜", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return btn
    }()
    
    let waveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("~", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return btn
    }()
    
    let lastButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("종료날짜", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return btn
    }()
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 20
        return sv
    }()
    
    let calendar : FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.scope = .month
        calendar.firstWeekday = 2
        calendar.placeholderType = .none
        calendar.allowsMultipleSelection = true
        calendar.appearance.todayColor = .clear
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.headerHeight = 55
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "yy년 MM월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.backgroundColor = .systemGray6
        calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .red
        return calendar
    }()
    
    let incomeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("수입", for: .normal)
        btn.backgroundColor = .systemGray6
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 5.0
        return btn
    }()
    
    let expenditureButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("지출", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5.0
        return btn
    }()
    
    let pieChartView: PieChartView = {
        let chartView = PieChartView()
        chartView.legend.font = UIFont.systemFont(ofSize: 15)
        return chartView
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장된 데이터가 없습니다."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
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
        
        addSubview(placeholderLabel)
        addSubview(startButton)
        addSubview(waveButton)
        addSubview(lastButton)
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(incomeButton)
        buttonStackView.addArrangedSubview(expenditureButton)
        addSubview(pieChartView)
        addSubview(calendar)
        
        placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.right.equalTo(waveButton.snp.left).offset(-10)
        }
        
        waveButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.centerX.equalToSuperview()
        }
        
        lastButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.left.equalTo(waveButton.snp.right).offset(10)
        }
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(lastButton.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-480)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(lastButton.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(100)
        }
        
        pieChartView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom)
            $0.left.right.bottom.equalTo(safeAreaLayoutGuide)
        }
        
    }
    
    
    
}
