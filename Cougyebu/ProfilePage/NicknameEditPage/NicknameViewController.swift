//
//  NicknameViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import RxSwift
import FirebaseAuth

class NicknameEditViewController: UIViewController {
    private let nicknameEditView = NicknameEditView()
    private let userManager = UserManager()
    private let user: Observable2<User>?
    private var checkNickname = false
    private let disposeBag = DisposeBag()
    
    init(user: Observable2<User>?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = nicknameEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTextField()
        setAddTarget()
    }
    
    
    func setNavigationBar() {
        self.title = "닉네임 변경"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    
    func setTextField(){
        nicknameEditView.nicknameTextField.delegate = self
    }
    
    func setAddTarget() {
        nicknameEditView.nicknameCheckButton.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        nicknameEditView.nicknameEditButton.addTarget(self, action: #selector(nicknameEditButtonTapped), for: .touchUpInside)
        nicknameEditView.nicknameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func nicknameCheckButtonTapped() {
        if let nickname = nicknameEditView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces), !nickname.isEmpty {
            userManager.findNickname(nickname: nickname)
                .subscribe(onNext: { [weak self] user in
                    if let user = user {
                        // 사용 불가능한 경우
                        AlertManager.showAlertOneButton(from: self!, title: "사용 불가능", message: "이미 사용중인 닉네임입니다.", buttonTitle: "확인")
                        self?.nicknameEditView.nicknameCheckButton.backgroundColor = .systemGray6
                        self?.nicknameEditView.nicknameCheckButton.setTitleColor(UIColor.black, for: .normal)
                        self?.checkNickname = false
                    } else {
                        // 사용 가능한 경우
                        AlertManager.showAlertOneButton(from: self!, title: "사용 가능", message: "사용 가능한 닉네임입니다. \n 입력하신 닉네임은 아이디 찾기시 이용됩니다.", buttonTitle: "확인")
                        self?.nicknameEditView.nicknameCheckButton.backgroundColor = .black
                        self?.nicknameEditView.nicknameCheckButton.setTitleColor(UIColor.white, for: .normal)
                        self?.checkNickname = true
                    }
                }, onError: { error in
                    // 오류 발생 시 처리
                    print("Error: \(error.localizedDescription)")
                    AlertManager.showAlertOneButton(from: self, title: "오류", message: error.localizedDescription, buttonTitle: "확인")
                }, onCompleted: {
                }).disposed(by: disposeBag)
        }
    }
    
    
    @objc func nicknameEditButtonTapped() {
        guard let newNickname = nicknameEditView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
              let userEmail = Auth.auth().currentUser?.email else {
            AlertManager.showAlertOneButton(from: self, title: "에러", message: "로그인된 사용자가 없습니다.", buttonTitle: "확인")
            return
        }
        
        guard !newNickname.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "입력 확인", message: "닉네임을 입력해주세요.", buttonTitle: "확인")
            return
        }
        
        guard checkNickname == true else {
            AlertManager.showAlertOneButton(from: self, title: "중복 확인", message: "닉네임 중복 확인을 해주세요.", buttonTitle: "확인")
            return
        }
        
        userManager.updateUserNickname(email: userEmail, updatedFields: ["nickname": newNickname])
            .subscribe(onNext: { success in
                if success {
                    AlertManager.showAlertOneButton(from: self, title: "닉네임 변경", message: "닉네임이 변경되었습니다.", buttonTitle: "확인") {
                        self.user?.value.nickname = newNickname
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    AlertManager.showAlertOneButton(from: self, title: "닉네임 변경 실패", message: "닉네임 변경에 실패했습니다.", buttonTitle: "확인")
                }
            }, onError: { error in
                print("Error: \(error.localizedDescription)")
                AlertManager.showAlertOneButton(from: self, title: "닉네임 변경 실패", message: "닉네임 변경에 실패했습니다.", buttonTitle: "확인")
            }, onCompleted: {}).disposed(by: disposeBag)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        nicknameEditView.nicknameCheckButton.backgroundColor = .systemGray6
        nicknameEditView.nicknameCheckButton.setTitleColor(UIColor.black, for: .normal)
        checkNickname = false
    }
    
}


// MARK: - UITextFieldDelegate
extension NicknameEditViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString input: String) -> Bool {
        if textField == nicknameEditView.nicknameTextField {
            
            let maxLength = 8
            let oldText = textField.text ?? ""
            let addedText = input
            let newText = oldText + addedText
            let newTextLength = newText.count
            
            if newTextLength <= maxLength {
                return true
            }
            
            let lastWordOfOldText = String(oldText[oldText.index(before: oldText.endIndex)])
            let separatedCharacters = lastWordOfOldText.decomposedStringWithCanonicalMapping.unicodeScalars.map{ String($0) }
            let separatedCharactersCount = separatedCharacters.count
            
            if separatedCharactersCount == 1 && !addedText.isConsonant {
                return true
            }
            if separatedCharactersCount == 2 && addedText.isConsonant {
                return true
            }
            if separatedCharactersCount == 3 && addedText.isConsonant {
                return true
            }
            return false
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        let text = textField.text ?? ""
        let maxLength = 8
        if text.count > maxLength {
            let startIndex = text.startIndex
            let endIndex = text.index(startIndex, offsetBy: maxLength - 1)
            let fixedText = String(text[startIndex...endIndex])
            textField.text = fixedText
        }
    }
}
