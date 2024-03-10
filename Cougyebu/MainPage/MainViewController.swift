//
//  MainViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FSCalendar

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let viewModel: MainViewModel
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    let dateFormatter = DateFormatter()
    var firstDate: Date?
    var lastDate: Date?
    var datesRange: [Date] = []
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddtarget()
        setCalendar()
        setTableView()
        setViewModelUser()
        loadPost()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategory()
        loadTotalCost()
    }
    
    func setAddtarget() {
        mainView.startButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        mainView.waveButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        mainView.lastButton.addTarget(self, action: #selector(showCalendar), for: .touchUpInside)
        mainView.floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    func setGesture() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleCalender(_:)))
        mainView.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    
    func setCalendar() {
        mainView.calendar.delegate = self
        mainView.calendar.isHidden = true
        dateFormatter.dateFormat = "yyyy.MM.dd"
    }
    
    func setTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
    }
    
    func setViewModelUser() {
        viewModel.setUser()
    }
    
    func setPlaceholderLabel() {
        if viewModel.observablePost.value.isEmpty {
            mainView.placeholderLabel.isHidden = false
        } else {
            mainView.placeholderLabel.isHidden = true
        }
    }
    
    func loadPost(date: String = Date().toString(format: "yyyy.MM.dd")) {
        viewModel.loadPost(email: viewModel.userEmail, date: date)
    }
    
    func loadCategory() {
        viewModel.loadCategory()
    }
    
    func loadTotalCost() {
        let cost = self.viewModel.addCost()
        mainView.totalLabel.text = "\(makeComma(num: cost))원"
    }
    
    func makeComma(num: Int) -> String {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let costResult: String = numberFormatter.string(for: num) ?? ""
        return costResult
    }
    
    func setBinding() {
        viewModel.observablePost.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.mainView.tableView.reloadData()
                self?.loadTotalCost()
                self?.setPlaceholderLabel()
            }
        }
    }
    
    func updateButtons() {
        if let startDate = firstDate, let endDate = lastDate {
            let startData = dateFormatter.string(from: startDate)
            let lastData = dateFormatter.string(from: endDate)
            mainView.startButton.setTitle(startData, for: .normal)
            mainView.lastButton.setTitle(lastData, for: .normal)
        }
    }
    
    // ✨ 데이터 선택하면 뷰모델에 로드하는 로직 필요
    //    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
    //        let selectedDate = sender.date
    //        let dateString = selectedDate.toString(format: "yyyy.MM.dd")
    //        viewModel.loadPost(email: viewModel.userEmail, date: dateString)
    //    }
    
    @objc func showCalendar() {
        print(#function)
        mainView.calendar.isHidden = false
        setGesture()
    }
    
    @objc func toggleCalender(_ sender: UITapGestureRecognizer) {
        mainView.calendar.isHidden = true
        mainView.tableView.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func floatingButtonTapped() {
        let postingVM = PostingViewModel(observablePost: viewModel.observablePost, userEmail: viewModel.userEmail, userCategory: viewModel.userCategory)
        let postingVC = PostingViewController(viewModel: postingVM)
        present(postingVC, animated: true)
    }
    
    
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.observablePost.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
        let post = viewModel.observablePost.value[indexPath.row]
        
        cell.categoryLabel.text = post.category
        cell.contentLabel.text = post.content
        cell.priceLabel.text = "\(post.cost)원"
        
        return cell
    }
    
}


// MARK: - FSCalendarDelegate
extension MainViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // case 1. 현재 아무것도 선택되지 않은 경우: 선택 date를 firstDate 설정
        if firstDate == nil {
            firstDate = date
            datesRange = [firstDate!]
            
            mainView.calendar.reloadData()
            updateButtons()
            return
        }
        
        // case 2. 현재 firstDate 하나만 선택된 경우
        if firstDate != nil && lastDate == nil {
            // case 2-1. firstDate 이전 날짜 선택: firstDate 변경
            if date < firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = [firstDate!]
                mainView.calendar.reloadData()
                updateButtons()
                return
            }
            // case 2-2. firstDate 이후 날짜 선택: 범위 선택
            else {
                var range: [Date] = []
                var currentDate = firstDate!
                while currentDate <= date {
                    range.append(currentDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                for day in range {
                    calendar.select(day)
                }
                lastDate = range.last
                datesRange = range
                mainView.calendar.reloadData()
                updateButtons()
                return
            }
        }
        
        // case 3. 두 개가 모두 선택되어 있는 상태 -> 현재 선택된 날짜 모두 해제 후 선택 날짜를 firstDate로 설정
        if firstDate != nil && lastDate != nil {
            
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            lastDate = nil
            firstDate = date
            calendar.select(date)
            datesRange = [firstDate!]
            mainView.calendar.reloadData()
            updateButtons()
            return
        }
    }
    
    
    // 이미 선택된 날짜들 중 하나를 선택 -> 선택된 날짜 모두 초기화
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let arr = datesRange
        if !arr.isEmpty {
            for day in arr {
                calendar.deselect(day)
            }
        }
        firstDate = nil
        lastDate = nil
        datesRange = []
        
        mainView.calendar.reloadData()
    }
    
    // 날짜 선택 개수 제한, 31개까지 선택 가능
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        if calendar.selectedDates.count > 30 {
            return false
        } else {
            return true
        }
    }
    
}



