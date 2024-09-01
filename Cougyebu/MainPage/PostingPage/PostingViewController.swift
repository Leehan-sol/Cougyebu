//
//  PostingViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit
import RxSwift
import RxCocoa

class PostingViewController: UIViewController {
    private let postingView = PostingView()
    private let viewModel: PostingViewModel
    
    private let disposeBag = DisposeBag()
    
    init(viewModel: PostingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = postingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setAction()
        setBinding()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUI() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let post = viewModel.post, let date = dateFormatter.date(from: post.date) {
            postingView.datePicker.date = date
            postingView.contentTextField.text = post.content
            postingView.costTextField.text = post.cost.removeComma(from: post.cost)
            postingView.addButton.setTitle("수정하기", for: .normal)
        }
        
        let groupObserver = Observable.just(viewModel.group)
        let selectedGroupCategories = BehaviorSubject<[String]>(value: viewModel.userExpenditureCategory)
        
        groupObserver
            .bind(to: postingView.groupPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)
        
        selectedGroupCategories
            .bind(to: postingView.categoryPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)
        
        groupObserver
                .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    
                    if let post = viewModel.post {
                        if let index = viewModel.group.firstIndex(of: post.group) {
                            postingView.groupPicker.selectRow(index, inComponent: 0, animated: true)
                            
                            let selectedCategories: [String]
                            if post.group == "수입" {
                                selectedCategories = viewModel.userIncomeCategory
                            } else {
                                selectedCategories = viewModel.userExpenditureCategory
                            }
                            
                            selectedGroupCategories.onNext(selectedCategories)
                            
                            if let categoryIndex = selectedCategories.firstIndex(of: post.category) {
                                postingView.categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
                            }
                        }
                    }
                }).disposed(by: disposeBag)
        
        postingView.groupPicker.rx.modelSelected(String.self)
            .map { [weak self] selectedGroupName -> [String] in
                guard let self = self else { return [] }
                if selectedGroupName.first == "수입" {
                    return viewModel.userIncomeCategory
                } else {
                    return viewModel.userExpenditureCategory
                }
            }
            .bind(to: selectedGroupCategories)
            .disposed(by: disposeBag)
    }
    

    
    // 뷰모델 로직 실행 (addButtonTapped x, 뷰모델 로직 실행으로 수정)
    func setAction() {
        postingView.addButton.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                addButtonTapped()
            }).disposed(by: disposeBag)
    }
    
    // 뷰모델 바인딩
    func setBinding() {
       
    }
    
    func addButtonTapped() {
        if viewModel.post == nil {
            let dateString = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
            
            let selectedGroupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            let group = viewModel.group[selectedGroupIndex]
            
            let categories: [String]
            //            if group == "수입" {
            //                categories = viewModel.userIncomeCategory
            //            } else {
            //                categories = viewModel.userExpenditureCategory
            //            }
            //
            let selectedCategoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
            //            let category = categories[selectedCategoryIndex]
            
            let uuid = UUID().uuidString
            
            guard let content = postingView.contentTextField.text, !content.trimmingCharacters(in: .whitespaces).isEmpty else {
                AlertManager.showAlertOneButton(from: self, title: "내용 입력", message: "내용을 입력하세요", buttonTitle: "확인")
                return
            }
            
            guard let cost = postingView.costTextField.text?.trimmingCharacters(in: .whitespaces) else {
                AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
                return
            }
            
            guard let intCost = Int(cost) else {
                AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
                return
            }
            let resultCost = intCost.makeComma(num: intCost)
            
            //            let post = Posts(date: dateString, group: group, category: category, content: content, cost: resultCost, uuid: uuid)
            //            viewModel.addPost(date: dateString, posts: post)
            dismiss(animated: true)
        } else {
            guard let post = viewModel.post else { return }
            let originalDate = post.date
            let dateString = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
            
            let selectedGroupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            let group = viewModel.group[selectedGroupIndex]
            
            let categories: [String]
            //            if group == "수입" {
            //                categories = viewModel.userIncomeCategory
            //            } else {
            //                categories = viewModel.userExpenditureCategory
            //            }
            
            let selectedCategoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
            //            let category = categories[selectedCategoryIndex]
            
            guard let content = postingView.contentTextField.text, !content.trimmingCharacters(in: .whitespaces).isEmpty else {
                AlertManager.showAlertOneButton(from: self, title: "내용 입력", message: "내용을 입력하세요", buttonTitle: "확인")
                return
            }
            
            guard let cost = postingView.costTextField.text, !cost.trimmingCharacters(in: .whitespaces).isEmpty else {
                AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
                return
            }
            guard let intCost = Int(cost) else {
                AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
                return
            }
            let resultCost = intCost.makeComma(num: intCost)
            
            //            let updatedPost = Posts(date: dateString, group: group, category: category, content: content, cost: resultCost, uuid: post.uuid)
            
            //            viewModel.updatePost(originalDate: originalDate, uuid: post.uuid, post: updatedPost) { bool in
            //                if bool == true {
            //                    AlertManager.showAlertOneButton(from: self, title: "수정", message: "수정되었습니다.", buttonTitle: "확인") {
            //                        self.dismiss(animated: true)
            //                    }
            //                } else {
            //                    AlertManager.showAlertOneButton(from: self, title: "수정 실패", message: "수정 실패했습니다.", buttonTitle: "확인")
            //                }
            //            }
        }
    }
    
    
}

