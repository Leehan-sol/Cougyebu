//
//  PasswordChangeViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/13.
//

import UIKit
import FirebaseAuth
import RxSwift

class PasswordChangeViewController: UIViewController {
    private let passwordChangeView = PasswordChangeView()
    private var viewModel: PasswordChangeViewProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: PasswordChangeViewProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = passwordChangeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setGesture()
        setAction()
        setbinding()
    }
    
    private func setNavigationBar() {
        self.title = "비밀번호 찾기"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    private func setGesture() {
        bindTextFieldsToMoveNext(fields: [
            passwordChangeView.registerIdTextField,
            passwordChangeView.authCodeTextField,
        ], disposeBag: disposeBag)
    }
    
    private func setAction() {
        passwordChangeView.authIdButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                guard let email = passwordChangeView.registerIdTextField.text else { return }
                viewModel.sendAuthCode(email: email)
            }).disposed(by: disposeBag)
        
        passwordChangeView.authCodeButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                guard let enteredCode = passwordChangeView.authCodeTextField.text else { return }
                viewModel.checkAuthCode(code: enteredCode)
            }).disposed(by: disposeBag)
        
        passwordChangeView.changePasswordButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                guard let userEmail = passwordChangeView.registerIdTextField.text else { return }
                viewModel.sendPasswordResetEmail(email: userEmail)
            }).disposed(by: disposeBag)
        
        passwordChangeView.registerIdTextField.rx.controlEvent(.editingChanged)
            .bind(onNext: { [weak self] in
                guard let self = self else { return }
                viewModel.sendEmailResult.onNext(false)
                viewModel.checkEmailAuthResult.onNext(false)
                viewModel.userAuthCode.onNext(Int.random(in: 1...10000))
            }).disposed(by: disposeBag)
    }
    
    private func setbinding() {
        viewModel.showAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (title, message) in
                AlertManager.showAlertOneButton(from: self!, title: title, message: message, buttonTitle: "확인")
            }).disposed(by: disposeBag)
        
        viewModel.showTimer
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] seconds in
                guard let self = self else { return }
                let min = seconds / 60
                let sec = seconds % 60
                passwordChangeView.timerLabel.isHidden = false
                passwordChangeView.timerLabel.text = String(format: "%d:%02d", min, sec)
            }).disposed(by: disposeBag)
        
        viewModel.invalidTimer
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                passwordChangeView.timerLabel.text = "시간만료"
                passwordChangeView.authIdButton.backgroundColor = .systemGray6
                passwordChangeView.authIdButton.setTitleColor(UIColor.black, for: .normal)
                passwordChangeView.authCodeButton.backgroundColor = .systemGray6
                passwordChangeView.authCodeButton.setTitleColor(UIColor.black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.sendEmailResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bool in
                guard let self = self else { return }
                passwordChangeView.authIdButton.backgroundColor = bool ? .black : .systemGray6
                passwordChangeView.authIdButton.setTitleColor(bool ? UIColor.white : UIColor.black, for: .normal)
            }).disposed(by: disposeBag)
        
        viewModel.checkEmailAuthResult
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] bool in
                guard let self = self else { return }
                passwordChangeView.timerLabel.isHidden = bool
                passwordChangeView.authIdButton.backgroundColor = bool ? .black : .systemGray6
                passwordChangeView.authIdButton.setTitleColor(bool ? UIColor.white : UIColor.black, for: .normal)
                passwordChangeView.authCodeButton.backgroundColor = bool ? .black : .systemGray6
                passwordChangeView.authCodeButton.setTitleColor(bool ? UIColor.white : UIColor.black, for: .normal)
                passwordChangeView.changePasswordButton.backgroundColor = bool ? .black : .systemGray6
                passwordChangeView.changePasswordButton.setTitleColor(bool ? UIColor.white : UIColor.black, for: .normal)
            }).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
}
