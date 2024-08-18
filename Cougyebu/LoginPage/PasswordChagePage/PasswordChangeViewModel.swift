//
//  PasswordChangeViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/31.
//

import Foundation
import FirebaseAuth
import RxSwift

// MARK: - PasswordViewProtocol
protocol PasswordChangeViewProtocol {
    func transform(input: PasswordChangeViewModel.Input) -> PasswordChangeViewModel.Output
}

// MARK: - PasswordChangeViewModel
class PasswordChangeViewModel: PasswordChangeViewProtocol {
    private let userManager = UserManager()
    private var seconds = 0
    private var timer: Timer?
    
    let userAuthCode = BehaviorSubject(value: Int.random(in: 1...10000))
    let showAlert = PublishSubject<(String, String)>()
    let showTimer = PublishSubject<Int>()
    let invalidTimer = PublishSubject<Void>()
    let sendEmailResult = BehaviorSubject(value: false)
    let checkEmailAuthResult = BehaviorSubject(value: false)
    private let disposeBag = DisposeBag()
    
    struct Input {
        let sendAuthCodeAction: PublishSubject<String>
        let checkAuthCodeAction: PublishSubject<String>
        let sendPasswordResetEmailAction: PublishSubject<String>
        let checkEmailAuthResultChanged: PublishSubject<Bool>
    }
    
    struct Output {
        let userAuthCode: BehaviorSubject<Int>
        let showAlert: PublishSubject<(String, String)>
        let showTimer: PublishSubject<Int>
        let invalidTimer: PublishSubject<Void>
        let sendEmailResult: BehaviorSubject<Bool>
        let checkEmailAuthResult: BehaviorSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.sendAuthCodeAction
            .bind(onNext: { email in
                self.sendAuthCode(email: email)
            }).disposed(by: disposeBag)
        
        input.checkAuthCodeAction
            .bind(onNext: { code in
                self.checkAuthCode(code: code)
            }).disposed(by: disposeBag)
        
        input.sendPasswordResetEmailAction
            .bind(onNext: { email in
                self.sendPasswordResetEmail(email: email)
            }).disposed(by: disposeBag)
        
        input.checkEmailAuthResultChanged
            .bind(onNext: { bool in
                self.checkEmailAuthResult.onNext(bool)
                self.userAuthCode.onNext(Int.random(in: 1...10000))
            }).disposed(by: disposeBag)
        
        return Output(userAuthCode: userAuthCode,
                      showAlert: showAlert,
                      showTimer: showTimer,
                      invalidTimer: invalidTimer,
                      sendEmailResult: sendEmailResult,
                      checkEmailAuthResult: checkEmailAuthResult)
    }
    
    private func sendAuthCode(email: String) {
        userManager.findId(email: email)
            .subscribe(onNext: { [weak self] isUsed in
                guard let self = self else { return }
                if isUsed {
                    seconds = 181
                    setTimer()
                    sendEmail(email: email)
                    sendEmailResult.onNext(true)
                } else {
                    self.showAlert.onNext(("이메일 찾기 실패", "가입되지 않은 이메일입니다."))
                    sendEmailResult.onNext(false)
                }
            }).disposed(by: disposeBag)
    }
    
    private func sendEmail(email: String) {
        SMTPManager.sendAuth(userEmail: email)
            .subscribe(onNext: { code in
                self.userAuthCode.onNext(code)
                self.showAlert.onNext(("인증 메일 발송", "인증 메일을 발송했습니다."))
            }, onError: { error in
                self.showAlert.onNext(("이메일 발송 실패", "이메일 발송을 실패했습니다. 다시 시도해주세요."))
            }).disposed(by: disposeBag)
    }
    
    private func setTimer() {
        timer?.invalidate()
        userAuthCode.onNext(Int.random(in: 1...10000))
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.seconds -= 1
            
            if self.seconds > 0 {
                self.showTimer.onNext(self.seconds)
            } else {
                invalidTimer.onNext(())
                userAuthCode.onNext(Int.random(in: 1...10000))
            }
        }
    }
    
    private func checkAuthCode(code: String) {
        if code == (try? String(userAuthCode.value())) {
            showAlert.onNext(("인증 성공", "인증 성공했습니다."))
            timer?.invalidate()
            checkEmailAuthResult.onNext(true)
        } else {
            showAlert.onNext(("인증 실패", "인증 실패했습니다. 다시 시도해주세요."))
            checkEmailAuthResult.onNext(false)
        }
    }

    private func sendPasswordResetEmail(email: String) {
        if (try? sendEmailResult.value()) == true && (try? checkEmailAuthResult.value()) == true {
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    print("재설정 이메일 전송실패: \(error.localizedDescription)")
                    self.showAlert.onNext(("메일 전송 실패", "비밀번호 재설정 이메일 발송에 실패했습니다. 다시 확인해주세요."))
                } else {
                    self.showAlert.onNext(("메일 전송", "비밀번호 재설정 이메일이 발송되었습니다."))
                }
            }
        } else {
            self.showAlert.onNext(("메일 전송 실패", "비밀번호 재설정 이메일 발송에 실패했습니다. 다시 확인해주세요."))
        }
    }
}
