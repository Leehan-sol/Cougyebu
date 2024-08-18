//
//  LoginViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let viewModel: LoginProtocol
    
    private let loginAction = PublishSubject<(String, String)>()
    private let findIdAction = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    init(viewModel: LoginProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setGesture()
        setAction()
        setBinding()
    }
    
    private func setNavigation() {
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setGesture() {
        loginView.showPwButton.showPasswordButtonToggle(textField: loginView.pwTextField, disposeBag: disposeBag)
        
        loginView.findPwButton.rx.tap
            .observe(on: MainScheduler.instance)
            .subscribe (onNext: { [weak self] in
                guard let self = self else { return }
                let passwordChangeVM = PasswordChangeViewModel()
                let passwordChangeVC = PasswordChangeViewController(viewModel: passwordChangeVM)
                self.navigationController?.pushViewController(passwordChangeVC, animated: true)
            }).disposed(by: disposeBag)
        
        loginView.registerButton.rx.tap
            .subscribe(onNext: {
                let registerVM = RegisterViewModel()
                let registerVC = RegisterViewController(viewModel: registerVM)
                self.navigationController?.pushViewController(registerVC, animated: true)
            }).disposed(by: disposeBag)
        
        loginView.findIdButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showFindIdAlert()
            }).disposed(by: disposeBag)
        
        animateLabelOnEditing(textField: loginView.idTextField, label: loginView.idLabel, centerYConstraint: loginView.idLabelCenterY, fontSize: 9)
        
        animateLabelOnEditing(textField: loginView.pwTextField, label: loginView.pwLabel, centerYConstraint: loginView.pwLabelCenterY, fontSize: 9)
        
        bindTextFieldsToMoveNext(fields: [
            loginView.idTextField,
            loginView.pwTextField,
        ], disposeBag: disposeBag)
    }
    
    private func setAction() {
        loginView.loginButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                guard let id = loginView.idTextField.text, let pw = loginView.pwTextField.text else { return }
                loginAction.onNext((id, pw))
            }.disposed(by: disposeBag)
    }
    
    private func showFindIdAlert() {
        AlertManager.showAlertWithOneTF(from: self,
                                        title: "아이디 찾기",
                                        message: "등록한 닉네임을 입력해주세요.",
                                        placeholder: "닉네임",
                                        button1Title: "찾기",
                                        button2Title: "취소") { [weak self] text in
            guard let self = self else { return }
            let nickname = text?.trimmingCharacters(in: .whitespaces) ?? ""
            
            if nickname.isEmpty {
                AlertManager.showAlertOneButton(from: self,
                                                title: "닉네임 입력",
                                                message: "닉네임을 입력해주세요.",
                                                buttonTitle: "확인")
            } else {
                findIdAction.onNext(nickname)
            }
        }
    }

    
    private func setBinding() {
        let input = LoginViewModel.Input(loginAction: loginAction, findIdAction: findIdAction)
        
        let output = viewModel.transform(input: input)
        
        output.showAlert
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (title, message) in
                AlertManager.showAlertOneButton(from: self!, title: title, message: message, buttonTitle: "확인")
            }).disposed(by: disposeBag)
        
        output.checkResult
            .subscribe(onNext: { bool in
                if bool {
                    NotificationCenter.default.post(name: .authStateDidChange, object: nil)
                }
            }).disposed(by: disposeBag)
    }
}



// MARK: - Extension
extension LoginViewController {
    
    private func animateLabelOnEditing(textField: UITextField, label: UILabel, centerYConstraint: NSLayoutConstraint, fontSize: CGFloat) {
        textField.rx.controlEvent(.editingDidBegin)
            .bind { [weak self] in
                guard let self = self else { return }
                animateLabel(label: label, centerYConstraint: centerYConstraint, fontSize: fontSize)
            }.disposed(by: disposeBag)
        
        textField.rx.controlEvent(.editingDidEnd)
            .bind { [weak self] in
                guard let self = self else { return }
                if let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), text == "" {
                    animateLabel(label: label, centerYConstraint: centerYConstraint, fontSize: fontSize == 9 ? 16 : 9)
                }
            }.disposed(by: disposeBag)
    }
    
    private func animateLabel(label: UILabel, centerYConstraint: NSLayoutConstraint, fontSize: CGFloat) {
        label.font = UIFont.systemFont(ofSize: fontSize)
        centerYConstraint.constant = fontSize == 9 ? -18 : 0
        UIView.animate(withDuration: 0.3) {
            self.loginView.layoutIfNeeded()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
