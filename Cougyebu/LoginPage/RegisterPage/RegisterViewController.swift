//
//  RegisterViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    private let registerView = RegisterView()
    private let viewModel: RegisterProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: RegisterProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setGesture()
        setAction()
        setBinding()
    }
    
    
    // MARK: - Methods
    private func setNavigationBar() {
        self.title = "회원가입"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    private func setGesture() {
        registerView.showPwButton.showPasswordButtonToggle(textField: registerView.pwTextField, disposeBag: disposeBag)
        registerView.showPwCheckButton.showPasswordButtonToggle(textField: registerView.pwCheckTextField, disposeBag: disposeBag)
        
        bindTextFieldsToMoveNext(fields: [
              registerView.idTextField,
              registerView.authTextField,
              registerView.nicknameTextField,
              registerView.pwTextField,
              registerView.pwCheckTextField
          ], disposeBag: disposeBag)
    }
    
    private func setAction() {
        registerView.sendEmailButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let email = registerView.idTextField.text, !email.isEmpty else {
                    AlertManager.showAlertOneButton(from: self, title: "이메일 입력", message: "이메일을 입력해주세요", buttonTitle: "확인")
                    return }
                viewModel.sendEmailForAuth(email: email)
            }).disposed(by: disposeBag)
        
        registerView.authButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let code = registerView.authTextField.text, !code.isEmpty else {
                    AlertManager.showAlertOneButton(from: self, title: "코드 입력", message: "코드를 입력해주세요", buttonTitle: "확인")
                    return }
                viewModel.checkAuthCode(code: code)
            }).disposed(by: disposeBag)
        
        registerView.nicknameCheckButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                guard let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces), !nickname.isEmpty else {
                    AlertManager.showAlertOneButton(from: self, title: "닉네임 입력", message: "닉네임을 입력해주세요", buttonTitle: "확인")
                    return
                }
                viewModel.checkNickname(nickname: nickname)
            }).disposed(by: disposeBag)
        
        registerView.registerButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if let email = registerView.idTextField.text?.trimmingCharacters(in: .whitespaces),
                   let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
                   let password = registerView.pwTextField.text?.trimmingCharacters(in: .whitespaces),
                   let checkPassword = registerView.pwCheckTextField.text?.trimmingCharacters(in: .whitespaces) {
                    viewModel.registerUser(email: email, nickname: nickname, password: password, checkPassword: checkPassword)
                }
            }).disposed(by: disposeBag)
    
        registerView.idTextField.rx.controlEvent(.editingChanged)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                viewModel.sendEmailResult.onNext(false)
                viewModel.checkEmailAuthResult.onNext(false)
                viewModel.userAuthCode.onNext(Int.random(in: 1...10000))
            }).disposed(by: disposeBag)
        
        registerView.nicknameTextField.rx.controlEvent(.editingChanged)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                viewModel.checkNicknameResult.onNext(false)
            }).disposed(by: disposeBag)
        
        registerView.nicknameTextField.rx.text.orEmpty
            .map { text -> String in
                let maxLength = 8
                if text.count > maxLength {
                    let resultText = String(text.prefix(maxLength))
                    DispatchQueue.main.async {
                        AlertManager.showAlertOneButton(from: self, title: "입력 오류", message: "닉네임은 8자 이하여야 합니다.", buttonTitle: "확인")
                    }
                    return resultText
                }
                return text
            }
            .bind(to: registerView.nicknameTextField.rx.text)
            .disposed(by: disposeBag)
    }

    
    private func setBinding() {
        let email = registerView.idTextField.rx.text.orEmpty
        let nickname = registerView.nicknameTextField.rx.text.orEmpty
        let password = registerView.pwTextField.rx.text.orEmpty
        let checkPassword = registerView.pwCheckTextField.rx.text.orEmpty
        let validEmail = viewModel.checkEmailAuthResult
        let validNickname = viewModel.checkNicknameResult
        
        Observable.combineLatest(email, nickname, password, checkPassword, validEmail, validNickname)
        .map { email, nickname, password, checkPassword, validEmail, validNickname in
            let isFormValid = !email.isEmpty && !nickname.isEmpty && !password.isEmpty && !checkPassword.isEmpty && validEmail && validNickname
            let backgroundColor: UIColor = isFormValid ? .black : .systemGray6
            let titleColor: UIColor = isFormValid ? .white : .black
            return (isFormValid, backgroundColor, titleColor)
        }
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak self] isFormValid, backgroundColor, titleColor in
            guard let self = self else { return }
            registerView.registerButton.isEnabled = isFormValid
            registerView.registerButton.backgroundColor = backgroundColor
            registerView.registerButton.setTitleColor(titleColor, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.showAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (title, message) in
                AlertManager.showAlertOneButton(from: self!, title: title, message: message, buttonTitle: "확인")
            }).disposed(by: disposeBag)
        
        viewModel.showTimer
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] seconds in
                guard let self = self else { return }
                let min = seconds / 60
                let sec = seconds % 60
                registerView.timerLabel.isHidden = false
                registerView.timerLabel.text = String(format: "%d:%02d", min, sec)
            }).disposed(by: disposeBag)
        
        viewModel.invalidTimer
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                registerView.timerLabel.text = "시간만료"
                registerView.sendEmailButton.backgroundColor = .systemGray6
                registerView.sendEmailButton.setTitleColor(UIColor.black, for: .normal)
                registerView.authButton.backgroundColor = .systemGray6
                registerView.authButton.setTitleColor(UIColor.black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.sendEmailResult
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] bool in
                guard let self = self else { return }
                registerView.sendEmailButton.backgroundColor = bool ? .black : .systemGray6
                registerView.sendEmailButton.setTitleColor(bool ? UIColor.white : UIColor.black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.checkEmailAuthResult
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] bool in
                guard let self = self else { return }
                registerView.timerLabel.isHidden = bool
                registerView.authButton.backgroundColor = bool ? .black : .systemGray6
                registerView.authButton.setTitleColor(bool ? .white : .black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.checkNicknameResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bool in
                guard let self = self else { return }
                registerView.nicknameCheckButton.backgroundColor = bool ? .black : .systemGray6
                registerView.nicknameCheckButton.setTitleColor(bool ? .white : .black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.doneRegister
            .observe(on: MainScheduler.instance)
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
