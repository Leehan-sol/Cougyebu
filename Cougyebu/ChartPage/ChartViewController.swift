//
//  ChartViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import UIKit
import Charts
import DGCharts
import FSCalendar

class ChartViewController: UIViewController {
    private let chartView = ChartView()
    private let viewModel: ChartViewModel
    private var tapGestureRecognizer: UITapGestureRecognizer!
    private var incomeOutcome: Bool? // 지출: false, 수입: true
    
    private let dateFormatter = DateFormatter()
    private var firstDate: Date?
    private var lastDate: Date?
    private lazy var datesRange: [String] = currentDate.getAllDatesInMonth()
    private let currentDate = Date()
    private lazy var startOfMonth = currentDate.startOfMonth().toString(format: "yyyy.MM.dd")
    private lazy var endOfMonth = currentDate.endOfMonth().toString(format: "yyyy.MM.dd")
    
    init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = chartView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddtarget()
        setButton()
        setCalendar()
        setBinding()
        setIncomeOutcome() // 초기값: 지출, 현재날짜기준 한달
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setViewModelUser()
    }
    
    func setAddtarget() {
        chartView.startButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        chartView.waveButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        chartView.lastButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        chartView.incomeButton.addTarget(self, action: #selector(incomeButtonTapped), for: .touchUpInside)
        chartView.expenditureButton.addTarget(self, action: #selector(expenditureButtonTapped), for: .touchUpInside)
    }
    
    func setButton() {
        chartView.startButton.setTitle(startOfMonth, for: .normal)
        chartView.lastButton.setTitle(endOfMonth, for: .normal)
    }
    
    func setCalendar() {
        chartView.calendar.delegate = self
        chartView.calendar.isHidden = true
        dateFormatter.dateFormat = "yyyy.MM.dd"
    }
    
    func setViewModelUser() {
        viewModel.setUser()
    }
    
    func setIncomeOutcome() {
        incomeOutcome = false
    }
    
    func setBinding() {
        viewModel.observablePost.bind { [weak self] posts in
            DispatchQueue.main.async {
                self?.setDataSource(posts: posts)
            }
        }
    }
    
    func setDataSource(posts: [Post]) {
        var categoryToSum: [String: Int] = [:]
        
        for post in posts {
            if incomeOutcome == false {
                if post.group == "지출" {
                    let costWithoutComma = post.cost.removeComma(from: post.cost)
                    categoryToSum[post.category, default: 0] += Int(costWithoutComma) ?? 0
                }
            } else {
                if post.group == "수입" {
                    let costWithoutComma = post.cost.removeComma(from: post.cost)
                    categoryToSum[post.category, default: 0] += Int(costWithoutComma) ?? 0
                }
            }
        }
        customizeChart(categoryToSum: categoryToSum)
    }
    
    
    func setGesture() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleCalender(_:)))
        chartView.pieChartView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func updateButtons() {
        if let startDate = firstDate, let lastDate = lastDate {
            let startData = dateFormatter.string(from: startDate)
            let lastData = dateFormatter.string(from: lastDate)
            chartView.startButton.setTitle(startData, for: .normal)
            chartView.lastButton.setTitle(lastData, for: .normal)
        }
    }
    
    func loadPost(dates: [String]) {
        viewModel.loadPost(dates: dates)
    }
    
    func customizeChart(categoryToSum: [String: Int]) {
        // 1. ChartDataEntry 세팅, 각 카테고리별 합산된 금액 사용
        var dataEntries: [ChartDataEntry] = []
        for (category, sum) in categoryToSum {
            let dataEntry = PieChartDataEntry(value: Double(sum), label: category)
            dataEntries.append(dataEntry)
        }
        
        // 2. ChartDataSet 세팅
        let pieChartDataSet = PieChartDataSet(entries: dataEntries, label: "")
        pieChartDataSet.colors = colorsOfCharts(count: categoryToSum.count)
        pieChartDataSet.valueColors = [.black]
        
        // 3. ChartData 설정
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        // 사용자 정의 포맷터 생성
        let valueFormatter = CurrencyValueFormatter(suffix: "원")
        pieChartData.setValueFormatter(valueFormatter)
        
        // 4. ChareView 설정
        chartView.pieChartView.holeRadiusPercent = 0
        chartView.pieChartView.data = pieChartData
    }

    
    private func colorsOfCharts(count: Int) -> [UIColor] {
        var colors: [UIColor] = []
        for _ in 0..<count {
            let red = CGFloat(arc4random_uniform(80)) + 175
            let green = CGFloat(arc4random_uniform(80)) + 175
            let blue = CGFloat(arc4random_uniform(80)) + 175
            let color = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
            colors.append(color)
        }
        return colors
    }

    
    
    // MARK: - @objc
    @objc func showCalendar() {
        chartView.calendar.isHidden = false
        setGesture()
    }
    
    @objc func toggleCalender(_ sender: UITapGestureRecognizer) {
        chartView.calendar.isHidden = true
        chartView.pieChartView.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func incomeButtonTapped() {
        chartView.incomeButton.backgroundColor = .black
        chartView.incomeButton.setTitleColor(.white, for: .normal)
        chartView.expenditureButton.backgroundColor = .systemGray6
        chartView.expenditureButton.setTitleColor(.black, for: .normal)
        incomeOutcome = true
        setDataSource(posts: viewModel.observablePost.value)
    }
    
    @objc func expenditureButtonTapped() {
        chartView.expenditureButton.backgroundColor = .black
        chartView.expenditureButton.setTitleColor(.white, for: .normal)
        chartView.incomeButton.backgroundColor = .systemGray6
        chartView.incomeButton.setTitleColor(.black, for: .normal)
        incomeOutcome = false
        setDataSource(posts: viewModel.observablePost.value)
    }
    
    
}



// MARK: - FSCalendarDelegate
extension ChartViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // case 1. 선택 x: 선택 date를 firstDate 설정
        if firstDate == nil {
            firstDate = date
            datesRange = []
            chartView.calendar.reloadData()
            return
        }
        
        //  case 2. firstDate 하나만 선택된 경우
        if firstDate != nil && lastDate == nil {
            // case 2-1. firstDate 이전 날짜 선택: firstDate 변경
            if date < firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = []
                chartView.calendar.reloadData()
                calendar.select(date)
                return
                // case 2-2. firstDate 이후 날짜 선택: 범위 선택
            } else {
                var range: [Date] = []
                var currentDate = firstDate!
                while currentDate <= date {
                    range.append(currentDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                
                var rangeString: [String] = []
                for day in range {
                    let dateString = dateFormatter.string(from: day)
                    rangeString.append(dateString)
                    calendar.select(day)
                }
                
                for dateString in rangeString {
                    datesRange.append(dateString)
                }
                firstDate = range.first
                lastDate = range.last
                datesRange = range.map { dateFormatter.string(from: $0) }
                chartView.calendar.reloadData()
                updateButtons()
                loadPost(dates: datesRange)
                return
            }
        }
        
        // case 3. 두개 선택: 선택날짜 전체해제 후 선택 날짜를 firstDate로 설정
        if firstDate != nil && lastDate != nil {
            
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            
            lastDate = nil
            firstDate = date
            datesRange = []
            calendar.select(date)
            chartView.calendar.reloadData()
            updateButtons()
            return
        }
    }
    
    // 선택된 날짜들중에 선택: 선택날짜 모두 초기화
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        for dateString in datesRange {
            if let day = dateFormatter.date(from: dateString) {
                calendar.deselect(day)
            }
        }
        firstDate = nil
        lastDate = nil
        datesRange = []
        
        chartView.calendar.reloadData()
    }
    
    // 날짜 31개까지 선택 가능
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if calendar.selectedDates.count > 31 {
            return false
        } else {
            return true
        }
    }
    
}
