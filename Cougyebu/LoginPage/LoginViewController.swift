//
//  LoginViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Combine
import UIKit
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
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    // MARK: - Methods
    func setNavigation(){
        navigationItem.leftBarButtonItem = nil
    }
    
    func setTextField(){
        loginView.idTextField.delegate = self
        loginView.pwTextField.delegate = self
    }
    
    func setAddTarget() {
        loginView.showPwButton.addTarget(self, action: #selector(showPwButtonTapped), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        loginView.findPwButton.addTarget(self, action: #selector(findPwButtonTapped), for: .touchUpInside)
        loginView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    private func bindViewToViewModel() {
        loginView.idTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.id, on: viewModel)
            .store(in: &cancelBags)
        
        loginView.pwTextField.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.password, on: viewModel)
            .store(in: &cancelBags)
    }
    
    private func bindViewModelToView() {
        viewModel.checkResult
            .sink { value in
                if let id = value {
                    self.loginSuccess(email: id)
                } else {
                    AlertManager.showAlertOneButton(from: self, title: "로그인 실패", message: "아이디 또는 비밀번호가 틀렸습니다.", buttonTitle: "확인")
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
        viewModel.loginButtonTapped()
    }

    func loginSuccess(email: String) {
           NotificationCenter.default.post(name: .authStateDidChange, object: nil)
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
            guard let self = self else { return }
            
            self.viewModel.findNickname(nickname)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        print("Error: \(error.localizedDescription)")
                        AlertManager.showAlertOneButton(from: self, title: "에러", message: "아이디를 찾는 도중 오류가 발생했습니다.", buttonTitle: "확인")
                    }
                }, receiveValue: { user in
                    var alertTitle: String
                    var alertMessage: String
                    
                    if let user = user {
                        alertTitle = "아이디 찾기 성공"
                        alertMessage = self.viewModel.maskEmail(email: user.email) 
                    } else {
                        alertTitle = "아이디 찾기 실패"
                        alertMessage = "해당 닉네임을 가진 사용자를 찾을 수 없습니다."
                    }
                    
                    AlertManager.showAlertOneButton(from: self, title: alertTitle, message: alertMessage, buttonTitle: "확인")
                })
                .store(in: &self.cancelBags)
        }
    }


    @objc func findPwButtonTapped() {
        let passwordChangeVM = PasswordChangeViewModel()
        let passwordChangeVC = PasswordChangeViewController(viewModel: passwordChangeVM)
        self.navigationController?.pushViewController(passwordChangeVC, animated: true)
    }
    
    @objc func registerButtonTapped() {
        let registerVC = RegisterViewController()
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
