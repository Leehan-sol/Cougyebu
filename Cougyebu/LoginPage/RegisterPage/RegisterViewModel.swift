//
//  RegisterViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/04/02.
//

import Foundation
import Combine
import FirebaseAuth

protocol RegisterViewProtocol: AnyObject {
    var userAuthCode: Int { get set }
    var checkEmail: Bool { get set }
    var checkNickname: Bool { get set }
    
    var showAlert: PassthroughSubject<(String, String), Never> { get }
    var showTimer: PassthroughSubject<Int, Never> { get }
    var invalidTimer: PassthroughSubject<Void, Never> { get }
    var checkEmailResult: PassthroughSubject<Bool, Never> { get }
    var checkAuthResult: PassthroughSubject<Bool, Never> { get }
    var checkNicknameResult: PassthroughSubject<Bool, Never> { get }
    var doneRegister: PassthroughSubject<Void, Never> { get }
    
    func sendEmailForAuth(email: String)
    func checkAuthCode(code: String)
    func checkNickname(nickname: String)
    func registerUser(email: String, nickname: String, password: String, checkPassword: String)
}

class RegisterViewModel: RegisterViewProtocol {
    
    private let userManager = UserManager()
    private var seconds = 0
    private var timer: Timer?
    var userAuthCode = 0
    var checkEmail = false
    var checkNickname = false
    
    let showAlert = PassthroughSubject<(String, String), Never>()
    let showTimer = PassthroughSubject<Int, Never>()
    let invalidTimer = PassthroughSubject<Void, Never>()
    let checkEmailResult = PassthroughSubject<Bool, Never>()
    let checkAuthResult = PassthroughSubject<Bool, Never>()
    let checkNicknameResult = PassthroughSubject<Bool, Never>()
    let doneRegister = PassthroughSubject<Void, Never>()
    
    private func isValidAuthCode(_ enteredCode: String) -> Bool {
        return enteredCode == String(userAuthCode)
    }
    
    private func setTimer() {
        timer?.invalidate()
        userAuthCode = Int.random(in: 1...10000)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
            
            if self.seconds > 0 {
                self.showTimer.send(self.seconds)
            } else {
                self.invalidTimer.send()
                self.userAuthCode = Int.random(in: 1...10000)
            }
        }
    }
    
    private func sendEmail(email: String) {
        DispatchQueue.global().async {
            SMTPManager.sendAuth(userEmail: email) { [weak self] (authCode, success) in
                guard let self = self else { return }
                if authCode >= 10000 && authCode <= 99999 && success {
                    self.userAuthCode = authCode
                }
            }
        }
    }
    
    func sendEmailForAuth(email: String) {
        guard email.isValidEmail() else {
            showAlert.send(("이메일 오류", "올바른 이메일 주소를 입력하세요."))
            return
        }
        userManager.findUser(email: email) { [weak self] isUsed in
            guard let self = self else { return }
            if isUsed != nil {
                showAlert.send(("사용 불가능", "이미 사용중인 아이디입니다."))
                checkEmailResult.send(false)
            } else {
                self.seconds = 181
                showAlert.send(("인증 메일 발송", "인증 메일을 발송했습니다."))
                setTimer()
                sendEmail(email: email)
                checkEmailResult.send(true)
            }
        }
    }
    
    func checkAuthCode(code: String) {
        if isValidAuthCode(code) {
            showAlert.send(("인증 성공", "인증 성공했습니다."))
            timer?.invalidate()
            checkAuthResult.send(true)
            checkEmail = true
        } else {
            showAlert.send(("인증 실패", "인증 실패했습니다. 다시 시도해주세요."))
            self.checkAuthResult.send(false)
        }
    }
    
    func checkNickname(nickname: String) {
        userManager.findNickname(nickname: nickname) { isUsed in
            if isUsed != nil {
                self.showAlert.send(("사용 불가능", "이미 사용중인 닉네임입니다."))
                self.checkNicknameResult.send(false)
            } else {
                self.showAlert.send(("사용 가능", "사용 가능한 닉네임입니다. \n 입력하신 닉네임은 아이디 찾기시 이용됩니다."))
                self.checkNicknameResult.send(true)
                self.checkNickname = true
            }
        }
    }
    
    
    func registerUser(email: String, nickname: String, password: String, checkPassword: String) {
        guard !email.isEmpty, !nickname.isEmpty, !password.isEmpty, !checkPassword.isEmpty else {
            showAlert.send(("입력 오류", "빈 필드가 있습니다. 모든 필드를 입력하세요."))
            return
        }
    
        guard checkEmail, checkNickname else {
            showAlert.send(("확인 필요", "이메일 인증과 닉네임 중복 확인을 완료해주세요."))
            return
        }
        
        guard validatePassword(password, checkPassword) != nil else { return }
        let newUser = User(email: email, nickname: nickname, isConnect: false, incomeCategory: ["💸 월급", "🐷 용돈", "💌 상여금"], expenditureCategory: ["🏡 생활비", "🍚 식비", "🚗 교통비"])
    
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert.send(("회원가입 실패", error.localizedDescription))
            } else {
                self.userManager.addUser(user: newUser)
                self.doneRegister.send()
            }
        }
    }

    private func validatePassword(_ password: String, _ checkPassword: String) -> String? {
        guard password == checkPassword else {
            showAlert.send(("비밀번호 불일치", "비밀번호가 일치하지 않습니다."))
            return nil
        }
        
        guard password.isValidPassword() else {
            showAlert.send(("유효하지 않은 비밀번호", "비밀번호는 대소문자, 특수문자, 숫자 8자 이상이여야합니다."))
            return nil
        }
        
        return password
    }

    
    
    
}
