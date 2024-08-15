//
//  LoginViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import Combine
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    private let viewModel: LoginViewProtocol
    private var cancelBags = Set<AnyCancellable>()
    
    init(viewModel: LoginViewProtocol) {
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
        setTextField()
        setAddTarget()
        bindViewModel()
    }
    
    // MARK: - Methods
    private func setNavigation(){
        navigationItem.leftBarButtonItem = nil
    }
    
    private func setTextField(){
        loginView.idTextField.delegate = self
        loginView.pwTextField.delegate = self
    }
    
    private func setAddTarget() {
        loginView.showPwButton.addTarget(self, action: #selector(showPwButtonTapped), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        loginView.findPwButton.addTarget(self, action: #selector(findPwButtonTapped), for: .touchUpInside)
        loginView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewModel() {
        viewModel.showAlert
            .sink { [weak self] (title, message) in
                AlertManager.showAlertOneButton(from: self!, title: title, message: message, buttonTitle: "확인")
            }
            .store(in: &cancelBags)
        
        viewModel.checkResult
            .sink { bool in
                if bool == true {
                    NotificationCenter.default.post(name: .authStateDidChange, object: nil)
                }
            }
            .store(in: &cancelBags)
    }
    
    
    // MARK: - @objc
    @objc func showPwButtonTapped(){
        loginView.showPwButton.isSelected.toggle()
        
        if loginView.showPwButton.isSelected {
            loginView.showPwButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            loginView.pwTextField.isSecureTextEntry = true
        } else {
            loginView.showPwButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            loginView.pwTextField.isSecureTextEntry = false
        }
        
    }
    
    @objc func loginButtonTapped() {
        guard let id = loginView.idTextField.text else { return }
        guard let pw = loginView.pwTextField.text else { return }
        
        viewModel.loginButtonTapped(id: id, password: pw)
    }
    
    @objc func findIdButtonTapped() {
        AlertManager.showAlertWithOneTF(from: self,
                                        title: "아이디 찾기",
                                        message: "등록한 닉네임을 입력해주세요.",
                                        placeholder: "닉네임",
                                        button1Title: "찾기",
                                        button2Title: "취소") { [weak self] text in
            guard let nickname = text?.trimmingCharacters(in: .whitespaces), !nickname.isEmpty else {
                AlertManager.showAlertOneButton(from: self!, title: "닉네임 입력", message: "닉네임을 입력해주세요.", buttonTitle: "확인")
                return
            }
            self?.viewModel.findId(nickname)
        }
    }
    
    @objc func findPwButtonTapped() {
        let passwordChangeVM = PasswordChangeViewModel()
        let passwordChangeVC = PasswordChangeViewController(viewModel: passwordChangeVM)
        self.navigationController?.pushViewController(passwordChangeVC, animated: true)
    }
    
    @objc func registerButtonTapped() {
        let registerVM = RegisterViewModel()
        let registerVC = RegisterViewController(viewModel: registerVM)
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.idTextField {
            loginView.pwTextField.becomeFirstResponder()
        } else if textField == loginView.pwTextField {
            loginButtonTapped()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == loginView.idTextField {
            animateLabel(label: loginView.idLabel, centerYConstraint: loginView.idLabelCenterY, fontSize: 9)
        }
        if textField == loginView.pwTextField {
            animateLabel(label: loginView.pwLabel, centerYConstraint: loginView.pwLabelCenterY, fontSize: 9)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == loginView.idTextField && textField.text == "" {
            animateLabel(label: loginView.idLabel, centerYConstraint: loginView.idLabelCenterY, fontSize: 16)
        }
        if textField == loginView.pwTextField && textField.text == "" {
            animateLabel(label: loginView.pwLabel, centerYConstraint: loginView.pwLabelCenterY, fontSize: 16)
        }
    }
    
    private func animateLabel(label: UILabel, centerYConstraint: NSLayoutConstraint, fontSize: CGFloat) {
        label.font = UIFont.systemFont(ofSize: fontSize)
        centerYConstraint.constant = fontSize == 9 ? -18 : 0
        UIView.animate(withDuration: 0.3) {
            self.loginView.layoutIfNeeded()
        }
    }
    
    
}
