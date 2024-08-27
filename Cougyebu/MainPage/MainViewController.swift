//
//  MainViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let viewModel: MainViewModel
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private let disposeBag = DisposeBag()
    
    private let dateFormatter = DateFormatter()
    private var firstDate: Date?
    private var lastDate: Date?
    private lazy var datesRange: [String] = currentDate.getAllDatesInMonth()
    private let currentDate = Date()
    private lazy var startOfMonth = currentDate.startOfMonth().toString(format: "yyyy.MM.dd")
    private lazy var endOfMonth = currentDate.endOfMonth().toString(format: "yyyy.MM.dd")

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
        setNavigationBar()
        setButton()
        setTableView()
        setCalendar()
        
        setGesture()
        setAction()
        setBinding()
    }
    
    func setNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        loadCategory()
//    } // Rx로 수정, 바인딩 1
    
    func setButton() {
        mainView.startButton.setTitle(startOfMonth, for: .normal)
        mainView.lastButton.setTitle(endOfMonth, for: .normal)
    } // Rx로 수정, 바인딩 2
    
    func setTableView() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
    }
    
    func setCalendar() { // 캘린더, 추후 수정
        mainView.calendar.delegate = self
        mainView.calendar.isHidden = true
        dateFormatter.dateFormat = "yyyy.MM.dd"
    }
    
    
    // 뷰컨 로직 실행
    func setGesture() {
        mainView.startButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                showCalendar()
            }).disposed(by: disposeBag)
        
        mainView.waveButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                showCalendar()
            }).disposed(by: disposeBag)
        
        mainView.lastButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                showCalendar()
            }).disposed(by: disposeBag)
        
        mainView.floatingButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
//                floatingButtonTapped()
            }).disposed(by: disposeBag)
    }
    
//        func floatingButtonTapped() { // 뷰컨 로직 실행으로 나중에 수정
//            let postingVM = PostingViewModel(observablePost: viewModel.observablePost, userEmail: viewModel.userEmail, coupleEmail: viewModel.coupleEmail ?? "", userIncomeCategory: viewModel.userIncomeCategory, userExpenditureCategory: viewModel.userExpenditureCategory)
//            postingVM.datesRange = datesRange
//            let postingVC = PostingViewController(viewModel: postingVM)
//            present(postingVC, animated: true)
//        }
    
    // 뷰모델 로직 실행
    func setAction() {
        
    }
    
    // 뷰모델 바인딩
    func setBinding() {
        viewModel.rxPosts
            .bind(to: mainView.tableView.rx.items(cellIdentifier: "MainCell", cellType: MainTableViewCell.self)) {
                index, item, cell in
                cell.configure(post: item)
            }.disposed(by: disposeBag)
        
    }

//    func loadPrice() { // Rx로 수정, 바인딩 3
//        let (totalIncome, totalExpenditure, totalPrice) = viewModel.calculatePrice()
//        mainView.incomePriceLabel.text = "\(totalIncome.makeComma(num: totalIncome))원"
//        mainView.expenditurePriceLabel.text = "\(totalExpenditure.makeComma(num: totalExpenditure))원"
//        mainView.sumPriceLabel.text = "\(totalPrice.makeComma(num: totalPrice))원"
//    }
    
//    func setPlaceholderLabel() { // Rx로 수정, 바인딩 4
//        if viewModel.observablePost.value.isEmpty {
//            mainView.placeholderLabel.isHidden = false
//        } else {
//            mainView.placeholderLabel.isHidden = true
//        }
//    }
    
//    func loadCategory() { // Rx로 수정, 바인딩 5
//        viewModel.loadCategory()
//    }
    
//    func loadPost(dates: [String]) {
//        viewModel.loadPost(dates: dates)
//    }
    
    func updateButtons() { // 캘린더, 추후 수정
        if let startDate = firstDate, let endDate = lastDate {
            let startData = dateFormatter.string(from: startDate)
            let lastData = dateFormatter.string(from: endDate)
            mainView.startButton.setTitle(startData, for: .normal)
            mainView.lastButton.setTitle(lastData, for: .normal)
        }
    }
    
    func showCalendar() {
        mainView.calendar.isHidden = false
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleCalender(_:)))
        mainView.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func toggleCalender(_ sender: UITapGestureRecognizer) {
        mainView.calendar.isHidden = true
        mainView.tableView.removeGestureRecognizer(tapGestureRecognizer)
    }
    
    

    
    
}
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        
//        let post = viewModel.observablePost.value[indexPath.row]
//        let postingVM = PostingViewModel(observablePost: viewModel.observablePost, userEmail: viewModel.userEmail, coupleEmail: viewModel.coupleEmail ?? "", userIncomeCategory: viewModel.userIncomeCategory, userExpenditureCategory: viewModel.userExpenditureCategory)
//        postingVM.post = post
//        postingVM.datesRange = datesRange
//        postingVM.indexPath = indexPath.row
//        let postingVC = PostingViewController(viewModel: postingVM)
//        
//        present(postingVC, animated: true)
//    }

    
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            let post = viewModel.observablePost.value[indexPath.row]
//            
//            viewModel.deletePost(date: post.date, uuid: post.uuid) { bool in
//                if bool == true {
//                    self.viewModel.observablePost.value.remove(at: indexPath.row)
//                    tableView.deleteRows(at: [indexPath], with: .fade)
//                } else {
//                    AlertManager.showAlertOneButton(from: self, title: "삭제 실패", message: "삭제 실패했습니다.", buttonTitle: "확인")
//                }
//            }
//        }
//    }




// MARK: - FSCalendarDelegate
extension MainViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 선택 x: 선택 date를 firstDate 설정
        if firstDate == nil {
            firstDate = date
            datesRange = []
            mainView.calendar.reloadData()
            return
        }
        
        //  firstDate 하나만 선택된 경우
        if firstDate != nil && lastDate == nil {
            // firstDate 이전 날짜 선택: firstDate 변경
            if date < firstDate! {
                calendar.deselect(firstDate!)
                firstDate = date
                datesRange = []
                mainView.calendar.reloadData()
                calendar.select(date)
                return
                // firstDate 이후 날짜 선택: 범위 선택
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
                mainView.calendar.reloadData()
                updateButtons()
//                loadPost(dates: datesRange)
                return
            }
        }

        // 두개 선택: 선택날짜 전체해제 후 선택 날짜를 firstDate로 설정
        if firstDate != nil && lastDate != nil {
            
            for day in calendar.selectedDates {
                calendar.deselect(day)
            }
            
            lastDate = nil
            firstDate = date
            datesRange = []
            calendar.select(date)
            mainView.calendar.reloadData()
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
        
        mainView.calendar.reloadData()
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



