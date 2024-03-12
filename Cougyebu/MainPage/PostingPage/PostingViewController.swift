//
//  PostingViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class PostingViewController: UIViewController {
    private let postingView = PostingView()
    private let viewModel: PostingViewModel
    private let group = ["지출", "수입"]
    private let charSet: CharacterSet = {
        var cs = CharacterSet.lowercaseLetters
        cs.insert(charactersIn: "0123456789")
        return cs.inverted
    }()
    var updatePostHandler: ((Posts) -> Void)?
    
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
        setTextField()
        setAddTarget()
        setPickerView()
        setUI()
    }
    
    func setTextField() {
        postingView.contentTextField.delegate = self
        postingView.costTextField.delegate = self
    }
    
    func setAddTarget() {
        postingView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    func setPickerView() {
        postingView.groupPicker.delegate = self
        postingView.groupPicker.dataSource = self
        postingView.categoryPicker.delegate = self
        postingView.categoryPicker.dataSource = self
    }
    
    func setUI() {
        guard let post = viewModel.post else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        if let date = dateFormatter.date(from: post.date) {
            postingView.datePicker.date = date
        }

        if let groupIndex = group.firstIndex(of: post.group) {
            postingView.groupPicker.selectRow(groupIndex, inComponent: 0, animated: true)
        }
        
        if post.group == "수입" {
            if let categoryIndex = viewModel.userIncomeCategory.firstIndex(of: post.category) {
                postingView.categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
            }
        } else {
            if let categoryIndex = viewModel.userExpenditureCategory.firstIndex(of: post.category) {
                postingView.categoryPicker.selectRow(categoryIndex, inComponent: 0, animated: true)
            }
        }
        
        postingView.contentTextField.text = post.content
        postingView.costTextField.text = post.cost.removeComma(from: post.cost)
        postingView.addButton.setTitle("수정하기", for: .normal)
    }

    
    @objc func addButtonTapped() {
        if viewModel.post == nil {
            let dateString = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
            
            let selectedGroupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            let group = group[selectedGroupIndex]
            
            let categories: [String]
            if group == "수입" {
                categories = viewModel.userIncomeCategory
            } else {
                categories = viewModel.userExpenditureCategory
            }
            
            let selectedCategoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
            let category = categories[selectedCategoryIndex]
            
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
            
            let post = Posts(date: dateString, group: group, category: category, content: content, cost: resultCost, uuid: uuid)
            viewModel.addPost(date: dateString, posts: [post])
            dismiss(animated: true)
        } else {
            guard let post = viewModel.post else { return }
            let dateString = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
            
            let selectedGroupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            let group = group[selectedGroupIndex]
            
            let categories: [String]
            if group == "수입" {
                categories = viewModel.userIncomeCategory
            } else {
                categories = viewModel.userExpenditureCategory
            }
            
            let selectedCategoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
            let category = categories[selectedCategoryIndex]
            
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
            
            let updatedPost = Posts(date: dateString, group: group, category: category, content: content, cost: resultCost, uuid: post.uuid)
            
            viewModel.updatePost(date: post.date, uuid: post.uuid, post: updatedPost) { bool in
                if bool == true {
                    self.updatePostHandler?(updatedPost)
                    self.dismiss(animated: true)
                } else {
                    AlertManager.showAlertOneButton(from: self, title: "수정 실패", message: "수정 실패했습니다.", buttonTitle: "확인")
                }
            }
        }
    }



    
    
}

// MARK: - UITextFieldDelegate
extension PostingViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == postingView.costTextField, string.count > 0 {
            guard string.rangeOfCharacter(from: charSet) == nil else { return false }
        }
        return true
    }
    
    
}


// MARK: - UIPickerViewDataSource, UIPickerViewDelegate
extension PostingViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == postingView.groupPicker {
            return 2
        } else {
            let groupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            return groupIndex == 0 ? viewModel.userExpenditureCategory.count : viewModel.userIncomeCategory.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == postingView.groupPicker {
            return group[row]
        } else {
            let groupIndex = postingView.groupPicker.selectedRow(inComponent: 0)
            return groupIndex == 0 ? viewModel.userExpenditureCategory[row] : viewModel.userIncomeCategory[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == postingView.groupPicker {
            postingView.categoryPicker.reloadComponent(0)
        }
    }
    
}

