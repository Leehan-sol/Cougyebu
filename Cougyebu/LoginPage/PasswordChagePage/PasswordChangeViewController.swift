//
//  PasswordChangeViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/13.
//

import UIKit
import Combine
import FirebaseAuth

class PasswordChangeViewController: UIViewController {
    private let passwordChangeView = PasswordChangeView()
    private var viewModel: PasswordChangeViewProtocol
    private var cancelBags = Set<AnyCancellable>()
    
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
        setAddTarget()
        setTextField()
        bindViewModel()
    }
    
    func setNavigationBar() {
        self.title = "비밀번호 찾기"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setAddTarget(){
        passwordChangeView.authIdButton.addTarget(self, action: #selector(authIdButtonTapped), for: .touchUpInside)
        passwordChangeView.authCodeButton.addTarget(self, action: #selector(authCodeButtonTapped), for: .touchUpInside)
        passwordChangeView.changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        passwordChangeView.registerIdTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setTextField(){
        passwordChangeView.registerIdTextField.delegate = self
        passwordChangeView.authCodeTextField.delegate = self
    }
    
    @objc func authIdButtonTapped() {
        guard let email = passwordChangeView.registerIdTextField.text else { return }
        viewModel.sendAuthCode(email: email)
    }
    
    @objc func authCodeButtonTapped(){
        guard let enteredCode = passwordChangeView.authCodeTextField.text else { return }
        viewModel.verifyAuthCode(enteredCode: enteredCode)
    }
    
    @objc func changePasswordButtonTapped() {
        guard let userEmail = passwordChangeView.registerIdTextField.text else { return }
        viewModel.sendPasswordResetEmail(email: userEmail)
    }
    
    @objc func idTextFieldDidChange(_ textField: UITextField) {
        passwordChangeView.authIdButton.backgroundColor = .systemGray6
        passwordChangeView.authIdButton.setTitleColor(.darkGray, for: .normal)
        passwordChangeView.authCodeButton.backgroundColor = .systemGray6
        passwordChangeView.authCodeButton.setTitleColor(.darkGray, for: .normal)
        passwordChangeView.changePasswordButton.backgroundColor = .systemGray6
        passwordChangeView.changePasswordButton.setTitleColor(.darkGray, for: .normal)
        viewModel.userAuthCode = Int.random(in: 1...10000)
        viewModel.checkEmail = false
    }
    
    func bindViewModel() {
        viewModel.showAlert
            .sink { [weak self] (title, message) in
                AlertManager.showAlertOneButton(from: self!, title: title, message: message, buttonTitle: "확인")
            }
            .store(in: &cancelBags)
        
        viewModel.showTimer
            .receive(on: DispatchQueue.main)
            .sink { [weak self] seconds in
                let min = seconds / 60
                let sec = seconds % 60
                self?.passwordChangeView.timerLabel.text = String(format: "%d:%02d", min, sec)
            }
            .store(in: &cancelBags)
        
        viewModel.invalidTimer
            .receive(on: DispatchQueue.main)
            .sink {
                self.passwordChangeView.timerLabel.text = "시간만료"
                self.passwordChangeView.authIdButton.backgroundColor = .systemGray6
                self.passwordChangeView.authIdButton.setTitleColor(UIColor.black, for: .normal)
                self.passwordChangeView.authCodeButton.backgroundColor = .systemGray6
                self.passwordChangeView.authCodeButton.setTitleColor(UIColor.black, for: .normal)
                self.viewModel.userAuthCode = Int.random(in: 1...10000)
            }
            .store(in: &cancelBags)
        
        viewModel.sendEmailForCheckId
            .sink { [weak self] isEnabled in
                self?.passwordChangeView.timerLabel.isHidden = false
                self?.passwordChangeView.authIdButton.backgroundColor = .black
                self?.passwordChangeView.authIdButton.setTitleColor(UIColor.white, for: .normal)
            }
            .store(in: &cancelBags)
        
        viewModel.checkAuthCode
            .sink { [weak self] isCorrect in
                self?.passwordChangeView.authCodeButton.backgroundColor = .black
                self?.passwordChangeView.authCodeButton.setTitleColor(UIColor.white, for: .normal)
                self?.passwordChangeView.changePasswordButton.backgroundColor = .black
                self?.passwordChangeView.changePasswordButton.setTitleColor(UIColor.white, for: .normal)
                self?.passwordChangeView.timerLabel.isHidden = true
            }
            .store(in: &cancelBags)
    }
    
}


// MARK: - UITextFieldDelegate
extension PasswordChangeViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordChangeView.registerIdTextField {
            passwordChangeView.authCodeTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}
