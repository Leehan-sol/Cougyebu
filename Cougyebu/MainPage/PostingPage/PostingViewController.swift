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
        setAction()
        setBinding()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // 뷰모델 로직 실행
    func setAction() {
        postingView.addButton.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                addOrUpdateButtonTapped()
            }).disposed(by: disposeBag)
        
        postingView.groupPicker.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] name in
                guard let self = self else { return }
                if let selectedGroupName = name.first {
                    viewModel.selectedGroupChange(name: selectedGroupName)
                }
            }).disposed(by: disposeBag)
    }
    
    // 뷰모델 바인딩
    func setBinding() {
        viewModel.post
            .subscribe(onNext: { [weak self] post in
                guard let self = self else { return }
                setUI(post: post)
            }).disposed(by: disposeBag)
        
        viewModel.group
            .bind(to: postingView.groupPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)

        viewModel.currentCategories
            .bind(to: postingView.categoryPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)
        
        viewModel.groupIndex
             .subscribe(onNext: { [weak self] index in
                 guard let self = self, let index = index else { return }
                 self.postingView.groupPicker.selectRow(index, inComponent: 0, animated: true)
             }).disposed(by: disposeBag)
        
        viewModel.categoryIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self, let index = index else { return }
                self.postingView.categoryPicker.selectRow(index, inComponent: 0, animated: true)
            }).disposed(by: disposeBag)
        
        viewModel.alertAction
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (title, message) in
                guard let self = self else { return }
                AlertManager.showAlertOneButton(from: self, title: title, message: message, buttonTitle: "확인")
            }).disposed(by: disposeBag)
        
        viewModel.dismissAction
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    
    func setUI(post: Posts?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let post = post, let date = dateFormatter.date(from: post.date) {
            postingView.datePicker.date = date
            postingView.contentTextField.text = post.content
            postingView.costTextField.text = post.cost.removeComma(from: post.cost)
            postingView.addButton.setTitle("수정하기", for: .normal)
        }
    }
    
    func addOrUpdateButtonTapped() {
        let date = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
        let groupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
        let categoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
        let content = postingView.contentTextField.text
        let cost = postingView.costTextField.text
        
        viewModel.addOrUpdatePost(date: date, 
                           groupIndex: groupIndex,
                           categoryIndex: categoryIndex,
                           content: content,
                           cost: cost)
    }

}

