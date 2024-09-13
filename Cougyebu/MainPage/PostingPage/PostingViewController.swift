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
    
    private let postAddOrUpdateAction = PublishSubject<(String, Int, Int, String?, String?)>()
    private let selectGroupChangeAction = PublishSubject<String>()
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
        setGesture()
        setAction()
        setBinding()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    private func setGesture() {
        postingView.costTextField.rx.controlEvent([.editingChanged])
               .asObservable()
               .subscribe(onNext: { [weak self] in
                   guard let self = self else { return }
                   if let text = self.postingView.costTextField.text?.filter({ $0.isNumber }), let number = Int(text) {
                       let formatted = number.makeComma(num: number)
                
                       let cursorPosition = self.postingView.costTextField.offset(from: postingView.costTextField.beginningOfDocument, to: self.postingView.costTextField.selectedTextRange!.start)
                       
                       postingView.costTextField.text = formatted
                       
                       if let newPosition = postingView.costTextField.position(from: postingView.costTextField.beginningOfDocument, offset: cursorPosition) {
                           postingView.costTextField.selectedTextRange = postingView.costTextField.textRange(from: newPosition, to: newPosition)
                       }
                   }
               }).disposed(by: disposeBag)
    }
    
    private func setAction() {
        postingView.addButton.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                addOrUpdateButtonTapped()
            }).disposed(by: disposeBag)
        
        postingView.groupPicker.rx.modelSelected(String.self)
            .subscribe(onNext: { [weak self] name in
                guard let self = self else { return }
                if let selectedGroupName = name.first {
                    selectGroupChangeAction.onNext(selectedGroupName)
                }
            }).disposed(by: disposeBag)
    }
    
    private func setBinding() {
        let input = PostingViewModel.Input(postAddOrUpdateAction: postAddOrUpdateAction, selectGroupChangeAction: selectGroupChangeAction)
        
        let output = viewModel.transform(input: input)
        
        output.alertAction
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (title, message) in
                guard let self = self else { return }
                AlertManager.showAlertOneButton(from: self, title: title, message: message, buttonTitle: "확인")
            }).disposed(by: disposeBag)
        
        output.dismissAction
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                dismiss(animated: true)
            }).disposed(by: disposeBag)
        
        output.post
            .subscribe(onNext: { [weak self] post in
                guard let self = self else { return }
                setUI(post: post)
            }).disposed(by: disposeBag)
        
        output.group
            .bind(to: postingView.groupPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)
        
        output.currentCategories
            .bind(to: postingView.categoryPicker.rx.itemTitles) { row, element in
                return element
            }.disposed(by: disposeBag)
        
        output.groupIndex
             .subscribe(onNext: { [weak self] index in
                 guard let self = self, let index = index else { return }
                 self.postingView.groupPicker.selectRow(index, inComponent: 0, animated: true)
             }).disposed(by: disposeBag)
        
        output.categoryIndex
            .subscribe(onNext: { [weak self] index in
                guard let self = self, let index = index else { return }
                self.postingView.categoryPicker.selectRow(index, inComponent: 0, animated: true)
            }).disposed(by: disposeBag)
        
     
    }
    
    
    private func setUI(post: Post?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let post = post, let date = dateFormatter.date(from: post.date) {
            postingView.datePicker.date = date
            postingView.contentTextField.text = post.content
            postingView.costTextField.text = post.cost
            postingView.addButton.setTitle("수정하기", for: .normal)
        }
    }
    
    private func addOrUpdateButtonTapped() {
        let date = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
        let groupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
        let categoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
        let content = postingView.contentTextField.text
        let cost = postingView.costTextField.text
        
        postAddOrUpdateAction.onNext((date, groupIndex, categoryIndex, content, cost))
    }

}

