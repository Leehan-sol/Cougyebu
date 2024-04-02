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

class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let registerView = RegisterView()
    // ✨ 의존성 주입으로 변경하기 
    private let viewModel = RegisterViewModel()
    // ✨ 지우기
    private let userManager = UserManager()
    private var userAuthCode = 0
    private var seconds = 181
    private var timer: Timer?
    private var checkEmail = false
    private var checkNickname = false
    
    // MARK: - Life Cycle
    override func loadView() {
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTextField()
        setAddTarget()
    }
    
    
    // MARK: - Methods
    func setNavigationBar() {
        self.title = "회원가입"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setTextField(){
        registerView.idTextField.delegate = self
        registerView.authTextField.delegate = self
        registerView.nicknameTextField.delegate = self
        registerView.pwTextField.delegate = self
        registerView.pwCheckTextField.delegate = self
    }
    
    func setAddTarget(){
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
    
    func isValidAuthCode(_ enteredCode: String) -> Bool {
        return enteredCode == String(userAuthCode)
    }
    
    func setTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [self] timer in
            self.seconds -= 1
            let min = self.seconds / 60
            let sec = self.seconds % 60
            
            if self.seconds > 0 {
                self.registerView.timerLabel.text = String(format: "%d:%02d", min, sec)
            } else {
                self.registerView.timerLabel.text = "시간만료"
                self.registerView.authButton.backgroundColor = .systemGray6
                self.registerView.authButton.setTitleColor(UIColor.black, for: .normal)
                self.userAuthCode = Int.random(in: 1...10000)
            }
        }
    }
    
    
    // MARK: - @objc
    @objc func sendEmailButtonTapped() {
        guard let email = registerView.idTextField.text else { return }
        if email.isEmpty {
            AlertManager.showAlertOneButton(from: self, title: "이메일 오류", message: "이메일 주소를 입력하세요.", buttonTitle: "확인")
            return
        } else if !email.isValidEmail() {
            AlertManager.showAlertOneButton(from: self, title: "이메일 오류", message: "올바른 이메일 주소를 입력하세요.", buttonTitle: "확인")
            return
        }
        
        userManager.findUser(email: email) { [weak self] isUsed in
            guard let self = self else { return }
            if isUsed != nil {
                AlertManager.showAlertOneButton(from: self, title: "사용 불가능", message: "이미 사용중인 아이디입니다.", buttonTitle: "확인")
                self.registerView.sendEmailButton.backgroundColor = .systemGray6
                self.registerView.sendEmailButton.setTitleColor(UIColor.black, for: .normal)
                self.checkEmail = false
            } else {
                if let timer = self.timer, timer.isValid {
                    timer.invalidate()
                    self.seconds = 181
                }
                AlertManager.showAlertOneButton(from: self, title: "인증 메일 발송", message: "인증 메일을 발송했습니다.", buttonTitle: "확인")
                { [weak self] in
                    self?.setTimer()
                    self?.registerView.timerLabel.isHidden = false
                }
                self.registerView.sendEmailButton.backgroundColor = .black
                self.registerView.sendEmailButton.setTitleColor(UIColor.white, for: .normal)
                
                DispatchQueue.global().async {
                    SMTPManager.sendAuth(userEmail: email) { [weak self] (authCode, success) in
                        guard let self = self else { return }
                        
                        if authCode >= 10000 && authCode <= 99999 && success {
                            userAuthCode = authCode
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func authButtonTapped(){
        guard let enteredCode = registerView.authTextField.text else { return }
        
        if isValidAuthCode(enteredCode) {
            AlertManager.showAlertOneButton(from: self, title: "인증 성공", message: "인증 성공했습니다.", buttonTitle: "확인")
            registerView.authButton.backgroundColor = .black
            registerView.authButton.setTitleColor(UIColor.white, for: .normal)
            timer?.invalidate()
            registerView.timerLabel.isHidden = true
            checkEmail = true
        } else {
            AlertManager.showAlertOneButton(from: self, title: "인증 실패", message: "인증 실패했습니다. 다시 시도해주세요.", buttonTitle: "확인")
        }
    }
    
    
    @objc func nicknameCheckButtonTapped() {
        if let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces) {
            if !nickname.isEmpty {
                userManager.findNickname(nickname: nickname) { isUsed in
                    if isUsed != nil {
                        AlertManager.showAlertOneButton(from: self, title: "사용 불가능", message: "이미 사용중인 닉네임입니다.", buttonTitle: "확인")
                        self.registerView.nicknameCheckButton.backgroundColor = .systemGray6
                        self.registerView.nicknameCheckButton.setTitleColor(UIColor.black, for: .normal)
                        self.checkNickname = false
                    } else {
                        AlertManager.showAlertOneButton(from: self, title: "사용 가능", message: "사용 가능한 닉네임입니다. \n 입력하신 닉네임은 아이디 찾기시 이용됩니다.", buttonTitle: "확인")
                        self.registerView.nicknameCheckButton.backgroundColor = .black
                        self.registerView.nicknameCheckButton.setTitleColor(UIColor.white, for: .normal)
                        self.checkNickname = true
                        self.writingComplete()
                    }
                }
            }
        }
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
    
    
    // 회원가입
    @objc func registerButtonTapped() {
        if let email = registerView.idTextField.text?.trimmingCharacters(in: .whitespaces),
           let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
           let password = registerView.pwTextField.text?.trimmingCharacters(in: .whitespaces),
           let checkPassword = registerView.pwCheckTextField.text?.trimmingCharacters(in: .whitespaces),
           checkEmail, checkNickname {
            let validPw = password.isValidPassword()
            if email.isEmpty {
                AlertManager.showAlertOneButton(from: self, title: "이메일", message: "이메일 주소를 입력하세요.", buttonTitle: "확인")
            } else if nickname.isEmpty {
                AlertManager.showAlertOneButton(from: self, title: "닉네임", message: "닉네임을 입력하세요.", buttonTitle: "확인")
            } else if password.isEmpty {
                AlertManager.showAlertOneButton(from: self, title: "비밀번호", message: "비밀번호를 입력하세요.", buttonTitle: "확인")
            } else if checkPassword.isEmpty {
                AlertManager.showAlertOneButton(from: self, title: "비밀번호 확인", message: "비밀번호를 다시 한번 입력하세요.", buttonTitle: "확인")
            } else if password != checkPassword {
                AlertManager.showAlertOneButton(from: self, title: "비밀번호 불일치", message: "비밀번호가 일치하지 않습니다.", buttonTitle: "확인")
            } else if !validPw {
                AlertManager.showAlertOneButton(from: self, title: "유효하지 않은 비밀번호", message: "비밀번호는 대소문자, 특수문자, 숫자 8자 이상이여야합니다.", buttonTitle: "확인")
            } else {
                let newUser = User(email: email, nickname: nickname, isConnect: false, incomeCategory: ["💸 월급", "🐷 용돈", "💌 상여금"], expenditureCategory: ["🏡 생활비", "🍚 식비", "🚗 교통비"])
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        AlertManager.showAlertOneButton(from: self, title: "오류", message: e.localizedDescription, buttonTitle: "확인")
                    } else {
                        self.userManager.addUser(user: newUser)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    @objc func idTextFieldDidChange(_ textField: UITextField) {
        registerView.sendEmailButton.backgroundColor = .systemGray6
        registerView.sendEmailButton.setTitleColor(.darkGray, for: .normal)
        registerView.authButton.backgroundColor = .systemGray6
        registerView.authButton.setTitleColor(.darkGray, for: .normal)
        userAuthCode = Int.random(in: 1...10000)
        checkEmail = false
    }
    
    @objc func nicknameTextFieldDidChange(_ textField: UITextField) {
        registerView.nicknameCheckButton.backgroundColor = .systemGray6
        registerView.nicknameCheckButton.setTitleColor(.darkGray, for: .normal)
        checkNickname = false
    }
    
    @objc func writingComplete() {
        if let email = registerView.idTextField.text?.trimmingCharacters(in: .whitespaces),
           let nickname = registerView.nicknameTextField.text?.trimmingCharacters(in: .whitespaces),
           let password = registerView.pwTextField.text?.trimmingCharacters(in: .whitespaces),
           let checkPassword = registerView.pwCheckTextField.text?.trimmingCharacters(in: .whitespaces) {
            let validEmail = email.isValidEmail()
            let isFormValid = !email.isEmpty && !nickname.isEmpty && !password.isEmpty && !checkPassword.isEmpty && checkEmail && checkNickname && validEmail
            
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
        if textField == registerView.authTextField {
            let numbersSet = CharacterSet(charactersIn: "0123456789")
            let replaceStringSet = CharacterSet(charactersIn: input)
            
            if !numbersSet.isSuperset(of: replaceStringSet) {
                AlertManager.showAlertOneButton(from: self, title: "입력 오류", message: "숫자를 입력해주세요.", buttonTitle: "확인")
                return false
            }
        } else if textField == registerView.nicknameTextField {
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
        if textField == registerView.nicknameTextField {
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
}

