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
    private let charSet: CharacterSet = {
        var cs = CharacterSet.lowercaseLetters
        cs.insert(charactersIn: "0123456789-")
        return cs.inverted
    }()
    
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
    }
    
    func setTextField() {
        postingView.contentTextField.delegate = self
        postingView.priceTextField.delegate = self
    }
    
    func setAddTarget() {
        postingView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    func setPickerView() {
        postingView.categoryPicker.delegate = self
        postingView.categoryPicker.dataSource = self
    }
    
    func makeComma(num: Int) -> String {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let costResult: String = numberFormatter.string(for: num) ?? ""
        return costResult
    }
    
    @objc func addButtonTapped() {
        let dateString = postingView.datePicker.date.toString(format: "yyyy.MM.dd")
        
        guard let content = postingView.contentTextField.text, !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "내용 입력", message: "내용을 입력하세요", buttonTitle: "확인")
            return
        }
        
        let selectedCategoryIndex = postingView.categoryPicker.selectedRow(inComponent: 0)
        let category = viewModel.userCategory[selectedCategoryIndex]
        let uuid = UUID().uuidString
        
        guard let cost = postingView.priceTextField.text?.trimmingCharacters(in: .whitespaces) else {
            AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
            return
        }
        guard let intCost = Int(cost) else {
            AlertManager.showAlertOneButton(from: self, title: "가격 입력", message: "가격을 입력하세요", buttonTitle: "확인")
            return
        }
        let resultCost = makeComma(num: intCost)
        
        viewModel.addPost(date: dateString, posts: [Posts(date: dateString, category: category, content: content, cost: resultCost, uuid: uuid)])
        dismiss(animated: true)
    }
    
    
}

// MARK: - UITextFieldDelegate
extension PostingViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == postingView.priceTextField, string.count > 0 {
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
        return viewModel.userCategory.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.userCategory[row]
    }
    
}
