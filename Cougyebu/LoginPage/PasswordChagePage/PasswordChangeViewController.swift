//
//  PasswordChangeViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/13.
//

import UIKit
import FirebaseAuth

class PasswordChangeViewController: UIViewController {
    private let passwordChangeView = PasswordChangeView()
    private let userManager = UserManager()
    
    private var userAuthCode = 0
    private var seconds = 181
    private var timer: Timer?
    private var checkEmail = false
    
    
    override func loadView() {
        view = passwordChangeView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addTarget()
        setTextField()
    }
    
    
    func setNavigationBar() {
        self.title = "비밀번호 찾기"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func addTarget(){
        passwordChangeView.authIdButton.addTarget(self, action: #selector(authIdButtonTapped), for: .touchUpInside)
        passwordChangeView.authCodeButton.addTarget(self, action: #selector(authCodeButtonTapped), for: .touchUpInside)
        passwordChangeView.changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        passwordChangeView.registerIdTextField.addTarget(self, action: #selector(idTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    func setTextField(){
        passwordChangeView.registerIdTextField.delegate = self
        passwordChangeView.authCodeTextField.delegate = self
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
                self.passwordChangeView.timerLabel.text = String(format: "%d:%02d", min, sec)
            } else {
                self.passwordChangeView.timerLabel.text = "시간만료"
                self.passwordChangeView.authIdButton.backgroundColor = .systemGray6
                self.passwordChangeView.authIdButton.setTitleColor(UIColor.black, for: .normal)
                self.passwordChangeView.authCodeButton.backgroundColor = .systemGray6
                self.passwordChangeView.authCodeButton.setTitleColor(UIColor.black, for: .normal)
                self.userAuthCode = Int.random(in: 1...10000)
            }
        }
    }
    
    // MARK: - @objc
    @objc func authIdButtonTapped() {
        guard let email = passwordChangeView.registerIdTextField.text else { return }
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
                if let timer = self.timer, timer.isValid {
                    timer.invalidate()
                    self.seconds = 181
                }
                AlertManager.showAlertOneButton(from: self, title: "인증 메일 발송", message: "인증 메일을 발송했습니다.", buttonTitle: "확인")
                { [weak self] in
                    self?.setTimer()
                    self?.passwordChangeView.timerLabel.isHidden = false
                }
                passwordChangeView.authIdButton.backgroundColor = .black
                passwordChangeView.authIdButton.setTitleColor(UIColor.white, for: .normal)
                
                DispatchQueue.global().async {
                    SMTPManager.sendAuth(userEmail: email) { [weak self] (authCode, success) in
                        guard let self = self else { return }
                        
                        if authCode >= 10000 && authCode <= 99999 && success {
                            userAuthCode = authCode
                        }
                    }
                }
            } else {
                AlertManager.showAlertOneButton(from: self, title: "이메일 찾기 실패", message: "가입되지 않은 이메일입니다.", buttonTitle: "확인")
            }
        }
    }
    
    @objc func authCodeButtonTapped(){
        guard let enteredCode = passwordChangeView.authCodeTextField.text else { return }
        
        if isValidAuthCode(enteredCode) {
            AlertManager.showAlertOneButton(from:self, title: "인증 성공", message: "인증 성공했습니다.", buttonTitle: "확인")
            passwordChangeView.authCodeButton.backgroundColor = .black
            passwordChangeView.authCodeButton.setTitleColor(UIColor.white, for: .normal)
            passwordChangeView.changePasswordButton.backgroundColor = .black
            passwordChangeView.changePasswordButton.setTitleColor(UIColor.white, for: .normal)
            timer?.invalidate()
            passwordChangeView.timerLabel.isHidden = true
            checkEmail = true
        } else {
            AlertManager.showAlertOneButton(from: self, title: "인증 실패", message: "인증 실패했습니다. 다시 시도해주세요.", buttonTitle: "확인")
        }
    }
    
    @objc func changePasswordButtonTapped() {
        if let userEmail = passwordChangeView.registerIdTextField.text {
            if checkEmail {
                Auth.auth().sendPasswordReset(withEmail: userEmail) { error in
                    if let error = error {
                        AlertManager.showAlertOneButton(from: self, title: "메일 전송 실패", message: "비밀번호 재설정 이메일 발송에 실패했습니다. 다시 확인해주세요.", buttonTitle: "확인")
                        print("재설정 이메일 전송실패: \(error.localizedDescription)")
                    } else {
                        AlertManager.showAlertOneButton(from: self, title: "메일 전송", message: "비밀번호 재설정 이메일이 발송되었습니다. 비밀번호를 변경 후 다시 로그인해주세요.", buttonTitle: "확인") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
            else {
                print("이메일 확인 실패")
            }
        }
    }
    
    @objc func idTextFieldDidChange(_ textField: UITextField) {
        passwordChangeView.authIdButton.backgroundColor = .systemGray6
        passwordChangeView.authIdButton.setTitleColor(.darkGray, for: .normal)
        passwordChangeView.authCodeButton.backgroundColor = .systemGray6
        passwordChangeView.authCodeButton.setTitleColor(.darkGray, for: .normal)
        passwordChangeView.changePasswordButton.backgroundColor = .systemGray6
        passwordChangeView.changePasswordButton.setTitleColor(.darkGray, for: .normal)
        userAuthCode = Int.random(in: 1...10000)
        checkEmail = false
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

