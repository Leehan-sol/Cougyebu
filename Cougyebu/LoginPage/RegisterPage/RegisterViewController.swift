//
//  RegisterViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import Combine
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let registerView = RegisterView()
    private let viewModel: RegisterViewProtocol
    private var cancelBags = Set<AnyCancellable>()
    
    // MARK: - Life Cycle
    init(viewModel: RegisterViewProtocol) {
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
        setTextField()
        setAddTarget()
        bindViewModel()
    }
    
    
    // MARK: - Methods
    private func setNavigationBar() {
        self.title = "회원가입"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    private func setTextField(){
        registerView.idTextField.delegate = self
        registerView.authTextField.delegate = self
        registerView.nicknameTextField.delegate = self
        registerView.pwTextField.delegate = self
        registerView.pwCheckTextField.delegate = self
    }
    
    private func setAddTarget(){
        registerView.sendEmailButton.addTarget(self, action: #selector(sendEmailButtonTapped), for: .touchUpInside)
        registerView.authButton.addTarget(self, action: #selector(authButtonTapped), for: .touchUpInside)
        registerView.nicknameCheckButton.addTarget(self, action: #selector(nicknameCheckButtonTapped), for: .touchUpInside)
        registerView.showPwButton.addTarget(self, action: #selector(showPwButtonTapped), for: .touchUpInside)
        registerView.showPwCheckButton.addTarget(self, action: #selector(showPwCheckButtonTapped), for: .touchUpInside)
        registerView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        
        registerView.idTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
        registerView.nicknameTextField.addTarget(self, action: #selector(nicknameTextFieldDidChange(_:)), for: .editingChanged)
        
        registerView.authButton.addTarget(self, action: #selector(writingComplete), for: .touchUpInside)
        registerView.nicknameCheckButton.addTarget(self, action: #selector(writingComplete), for: .touchUpInside)
        registerView.pwTextField.addTarget(self, action: #selector(writingComplete), for: .editingChanged)
        registerView.pwCheckTextField.addTarget(self, action: #selector(writingComplete), for: .editingChanged)
    }
    
    private func bindViewModel() {
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
                self?.registerView.timerLabel.text = String(format: "%d:%02d", min, sec)
            }
            .store(in: &cancelBags)
        
        viewModel.invalidTimer
            .receive(on: DispatchQueue.main)
            .sink {
                self.registerView.timerLabel.text = "시간만료"
                self.registerView.authButton.backgroundColor = .systemGray6
                self.registerView.authButton.setTitleColor(UIColor.black, for: .normal)
            }
            .store(in: &cancelBags)
        
        viewModel.checkEmailResult
            .sink { [weak self] bool in
                self?.registerView.timerLabel.isHidden = bool ? false : true
                self?.registerView.sendEmailButton.backgroundColor = bool ? .black : .systemGray6
                self?.registerView.sendEmailButton.setTitleColor(bool ? .white : .black, for: .normal)
            }
            .store(in: &cancelBags)
        
        viewModel.checkAuthResult
            .sink { [weak self] bool in
                self?.registerView.timerLabel.isHidden = bool ? true : false
                self?.registerView.authButton.backgroundColor = bool ? .black : .systemGray6
                self?.registerView.authButton.setTitleColor(bool ? .white : .black, for: .normal)
            }
            .store(in: &cancelBags)
        
        viewModel.checkNicknameResult
            .sink { [weak self] bool in
                self?.registerView.nicknameCheckButton.backgroundColor = bool ? .black : .systemGray6
                self?.registerView.nicknameCheckButton.setTitleColor(bool ? .white : .black, for: .normal)
            }
            .store(in: &cancelBags)
        
        viewModel.doneRegister
            .sink { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancelBags)
    }
    
    
    // MARK: - @objc
    @objc func sendEmailButtonTapped() {
        guard let email = registerView.idTextField.text, !email.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "이메일 입력", message: "이메일을 입력해주세요", buttonTitle: "확인")
            return }
        viewModel.sendEmailForAuth(email: email)
    }
    
    @objc func authButtonTapped(){
        guard let code = registerView.authTextField.text, !code.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "코드 입력", message: "코드를 입력해주세요", buttonTitle: "확인")
            return }
        viewModel.checkAuthCode(code: code)
    }
    
    @objc func nicknameCheckButtonTapped() {
        guard let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces), !nickname.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "닉네임 입력", message: "닉네임을 입력해주세요", buttonTitle: "확인")
            return
        }
        viewModel.checkNickname(nickname: nickname)
    }
    
    @objc func showPwButtonTapped(){
        registerView.showPwButton.isSelected.toggle()
        
        if registerView.showPwButton.isSelected {
            registerView.showPwButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            registerView.pwTextField.isSecureTextEntry = true
        } else {
            registerView.showPwButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            registerView.pwTextField.isSecureTextEntry = false
        }
    }
    
    @objc func showPwCheckButtonTapped(){
        registerView.showPwCheckButton.isSelected.toggle()
        
        if registerView.showPwCheckButton.isSelected {
            registerView.showPwCheckButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            registerView.pwCheckTextField.isSecureTextEntry = true
        } else {
            registerView.showPwCheckButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            registerView.pwCheckTextField.isSecureTextEntry = false
        }
    }
    
    @objc func registerButtonTapped() {
        if let email = registerView.idTextField.text?.trimmingCharacters(in: .whitespaces),
           let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
           let password = registerView.pwTextField.text?.trimmingCharacters(in: .whitespaces),
           let checkPassword = registerView.pwCheckTextField.text?.trimmingCharacters(in: .whitespaces) {
            viewModel.registerUser(email: email, nickname: nickname, password: password, checkPassword: checkPassword)
        }
    }
    
    @objc func idTextFieldDidChange(_ textField: UITextField) {
        registerView.sendEmailButton.backgroundColor = .systemGray6
        registerView.sendEmailButton.setTitleColor(.black, for: .normal)
        registerView.authButton.backgroundColor = .systemGray6
        registerView.authButton.setTitleColor(.black, for: .normal)
        viewModel.userAuthCode = Int.random(in: 1...10000)
        viewModel.checkEmail = false
    }
    
    @objc func nicknameTextFieldDidChange(_ textField: UITextField) {
        registerView.nicknameCheckButton.backgroundColor = .systemGray6
        registerView.nicknameCheckButton.setTitleColor(.black, for: .normal)
        viewModel.checkNickname = false
    }
    
    @objc func writingComplete() {
        if let email = registerView.idTextField.text?.trimmingCharacters(in: .whitespaces),
           let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
           let password = registerView.pwTextField.text?.trimmingCharacters(in: .whitespaces),
           let checkPassword = registerView.pwCheckTextField.text?.trimmingCharacters(in: .whitespaces) {
            let isFormValid = !email.isEmpty && !nickname.isEmpty && !password.isEmpty && !checkPassword.isEmpty && viewModel.checkEmail && viewModel.checkNickname
            
            UIView.animate(withDuration: 0.3) {
                if isFormValid {
                    self.registerView.registerButton.backgroundColor = .black
                    self.registerView.registerButton.setTitleColor(UIColor.white, for: .normal)
                    self.registerView.registerButton.isEnabled = true
                } else {
                    self.registerView.registerButton.backgroundColor = .systemGray6
                    self.registerView.registerButton.isEnabled = false
                }
            }
        }
    }
}



//MARK: - UITextFieldDelegate
extension RegisterViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerView.idTextField {
            registerView.authTextField.becomeFirstResponder()
        } else if textField == registerView.authTextField {
            registerView.nicknameTextField.becomeFirstResponder()
        } else if textField == registerView.nicknameTextField {
            registerView.pwTextField.becomeFirstResponder()
        } else if textField == registerView.pwTextField {
            registerView.pwCheckTextField.becomeFirstResponder()
        }
        return true
    }
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString input: String) -> Bool {
        switch textField {
        case registerView.authTextField:
            let numbersSet = CharacterSet(charactersIn: "0123456789")
            let replaceStringSet = CharacterSet(charactersIn: input)
            
            if !numbersSet.isSuperset(of: replaceStringSet) {
                DispatchQueue.main.async {
                    AlertManager.showAlertOneButton(from: self, title: "입력 오류", message: "숫자를 입력해주세요.", buttonTitle: "확인")
                }
                return false
            }
        case registerView.nicknameTextField:
            let maxLength = 8
            let oldText = textField.text ?? ""
            let newText = (oldText as NSString).replacingCharacters(in: range, with: input)
            
            if newText.count > maxLength {
                DispatchQueue.main.async {
                    AlertManager.showAlertOneButton(from: self, title: "입력 오류", message: "닉네임은 8자 이하여야 합니다.", buttonTitle: "확인")
                }
                return false
            }
        default:
            break
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        switch textField {
        case registerView.nicknameTextField:
            let maxLength = 8
            guard let text = textField.text, text.count > maxLength else { return }
            
            let endIndex = text.index(text.startIndex, offsetBy: maxLength)
            DispatchQueue.main.async {
                textField.text = String(text.prefix(upTo: endIndex))
            }
        default:
            break
        }
    }
    
}

