//
//  PasswordChangeViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/31.
//

import Combine
import Foundation
import FirebaseAuth

// MARK: - PasswordViewProtocol
protocol PasswordChangeViewProtocol {
    var userManager: UserManager { get }
    var seconds: Int { get set }
    var userAuthCode: Int { get set }
    var timer: Timer? { get set }
    var checkEmail: Bool { get set }
    
    var showAlert: PassthroughSubject<(String, String), Never> { get } // 👉🏻 로그인페이지도 변경하기
    var showTimer: PassthroughSubject<Int, Never> { get }
    var invalidTimer: PassthroughSubject<Void, Never> { get }
    var sendEmailForCheckId: PassthroughSubject<Bool, Never> { get }
    var checkAuthCode: PassthroughSubject<Bool, Never> { get }
    
    func sendAuthCode(email: String)
    func verifyAuthCode(enteredCode: String)
    func sendPasswordResetEmail(email: String)
}

// MARK: - PasswordChangeViewModel
class PasswordChangeViewModel: PasswordChangeViewProtocol {
    let userManager = UserManager()
    var seconds = 181
    var userAuthCode = 0
    var timer: Timer?
    var checkEmail = false
    
    var showAlert = PassthroughSubject<(String, String), Never>()
    var showTimer = PassthroughSubject<Int, Never>()
    var invalidTimer = PassthroughSubject<Void, Never>()
    var sendEmailForCheckId = PassthroughSubject<Bool, Never>()
    var checkAuthCode = PassthroughSubject<Bool, Never>()
    
    
    func setTimer() {
        timer?.invalidate()
        userAuthCode = Int.random(in: 1...10000)
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
            
            if self.seconds > 0 {
                self.showTimer.send(self.seconds)
            } else {
                self.invalidTimer.send()
            }
        }
    }
    
    func sendAuthCode(email: String) {
        userManager.findUser(email: email) { [weak self] user in
            guard let self = self else { return }
            if user != nil {
                if let timer = self.timer, timer.isValid {
                    timer.invalidate()
                    self.seconds = 181
                }
                self.setTimer()
                self.sendEmailForCheckId.send(true)
                self.showAlert.send(("인증 메일 발송", "인증 메일을 발송했습니다."))
                
                DispatchQueue.global().async {
                    SMTPManager.sendAuth(userEmail: email) { [weak self] (authCode, success) in
                        guard let self = self else { return }
                        if authCode >= 10000 && authCode <= 99999 && success {
                            self.userAuthCode = authCode
                        }
                    }
                }
            } else {
                self.showAlert.send(("이메일 찾기 실패", "가입되지 않은 이메일입니다."))
            }
        }
    }
    
    func verifyAuthCode(enteredCode: String) {
        if isValidAuthCode(enteredCode) {
            showAlert.send(("인증 성공", "인증 성공했습니다."))
            checkEmail = true
            self.timer?.invalidate()
            self.checkAuthCode.send(true)
        } else {
            showAlert.send(("인증 실패", "인증 실패했습니다. 다시 시도해주세요."))
        }
    }
    
    func isValidAuthCode(_ enteredCode: String) -> Bool {
        return enteredCode == String(userAuthCode)
    }
    
    func sendPasswordResetEmail(email: String) {
        if checkEmail {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print("재설정 이메일 전송실패: \(error.localizedDescription)")
                    self.showAlert.send(("메일 전송 실패", "비밀번호 재설정 이메일 발송에 실패했습니다. 다시 확인해주세요."))
                } else {
                    self.showAlert.send(("메일 전송", "비밀번호 재설정 이메일이 발송되었습니다."))
                }
            }
        } else {
            print("이메일 확인 실패")
        }
    }
}
