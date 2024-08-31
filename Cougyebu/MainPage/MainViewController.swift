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
        setTableView()
        setCalendar()
        
        setGesture()
        setAction()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.loadCategory()
    }
    
    
    func setNavigationBar() {
        navigationController?.isNavigationBarHidden = true
    }
    
    func setTableView() {
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
    }
    
    func setCalendar() {
        mainView.calendar.delegate = self
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
    }
    
    // 뷰모델 로직 실행
    func setAction() {
        // 📌 테이블뷰 선택시 게시글 수정 로직
        //        recordView.recordTableView.rx.itemSelected
        //            .subscribe(onNext: { [weak self] indexPath in
        //                self?.recordView.recordTableView.deselectRow(at: indexPath, animated: true)
        //                self?.saveReadNewsAction.onNext(indexPath.row)
        //            }).disposed(by: disposeBag)
        
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
        
        mainView.tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                mainView.tableView.beginUpdates()
                viewModel.deletePost(index: indexPath.row)
                mainView.tableView.endUpdates()
            }).disposed(by: disposeBag)
        
        mainView.floatingButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                viewModel.makePostViewModel()
            }).disposed(by: disposeBag)
    }
    
    // 뷰모델 바인딩
    func setBinding() {
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] bool in
                guard let self = self else { return }
                bool ? mainView.indicatorView.startAnimating() : mainView.indicatorView.stopAnimating()
            }.disposed(by: disposeBag)
        
        viewModel.firstDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                mainView.calendar.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.existingFirstDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                if let date = date {
                    mainView.calendar.deselect(date)
                }
            }).disposed(by: disposeBag)
        
        viewModel.selecteDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                mainView.calendar.select(date)
            }).disposed(by: disposeBag)
        
        viewModel.deselecteDate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] date in
                guard let self = self else { return }
                if let date = date {
                    mainView.calendar.deselect(date)
                }
            }).disposed(by: disposeBag)
     
        viewModel.needLoadDates
            .subscribe(onNext: { [weak self] dates in
                guard let self = self else { return }
                mainView.startButton.setTitle(dates.first, for: .normal)
                mainView.lastButton.setTitle(dates.last, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.rxPosts
            .map { !($0.isEmpty) }
            .bind(to: mainView.placeholderLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.rxPosts
            .bind(to: mainView.tableView.rx.items(cellIdentifier: "MainCell", cellType: MainTableViewCell.self)) {
                index, item, cell in
                cell.configure(post: item)
            }.disposed(by: disposeBag)
        
        viewModel.postsPrice
            .subscribe(onNext: { [weak self] (income, expenditure, result) in
                guard let self = self else { return }
                mainView.incomePriceLabel.text = "\(income.makeComma(num: income))원"
                mainView.expenditurePriceLabel.text = "\(expenditure.makeComma(num: expenditure))원"
                mainView.sumPriceLabel.text = "\(result.makeComma(num: result))원"
            }).disposed(by: disposeBag)
        
        viewModel.movePostPage
            .subscribe(onNext: { [weak self] viewModel in
                guard let self = self else { return }
                let postingVC = PostingViewController(viewModel: viewModel)
                present(postingVC, animated: true)
            }).disposed(by: disposeBag)
    }
    
    
    func showCalendar() {
        mainView.calendar.isHidden.toggle()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleCalender(_:)))
        mainView.tableView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func toggleCalender(_ sender: UITapGestureRecognizer) {
        mainView.calendar.isHidden = true
        mainView.tableView.removeGestureRecognizer(tapGestureRecognizer)
    }
    
}



// MARK: - FSCalendarDelegate
extension MainViewController: FSCalendarDelegate {
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.handleDateSelection(selectDate: date)
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.handleDateDeselection(deselectDate: date)
    }
    
}



