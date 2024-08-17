//
//  RegisterViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/04/02.
//

import Foundation
import FirebaseAuth
import RxSwift

// MARK: - RegisterProtocol
protocol RegisterProtocol: AnyObject {
    var userAuthCode: BehaviorSubject<Int> { get }
    
    var showAlert: PublishSubject<(String, String)> { get }
    var showTimer: PublishSubject<Int> { get }
    var invalidTimer: PublishSubject<Void> { get }
    
    var sendEmailResult: PublishSubject<Bool> { get }
    var checkEmailAuthResult: BehaviorSubject<Bool> { get }
    var checkNicknameResult: BehaviorSubject<Bool> { get }
    var doneRegister: PublishSubject<Void> { get }
    
    func sendEmailForAuth(email: String)
    func checkAuthCode(code: String)
    func checkNickname(nickname: String)
    func registerUser(email: String, nickname: String, password: String, checkPassword: String)
}


// MARK: - RegisterViewModel
class RegisterViewModel: RegisterProtocol {
    
    private let userManager = UserManager()
    private var seconds = 0
    private var timer: Timer?
    
    let userAuthCode = BehaviorSubject(value: Int.random(in: 1...10000))
    let showAlert = PublishSubject<(String, String)>()
    let showTimer = PublishSubject<Int>()
    let invalidTimer = PublishSubject<Void>()
    
    let sendEmailResult = PublishSubject<Bool>()
    let checkEmailAuthResult = BehaviorSubject(value: false)
    let checkNicknameResult = BehaviorSubject(value: false)
    let doneRegister = PublishSubject<Void>()
    
    private let disposeBag = DisposeBag()
    
    func sendEmailForAuth(email: String) {
        guard email.isValidEmail() else {
            showAlert.onNext(("이메일 오류", "올바른 이메일 주소를 입력하세요."))
            return
        }
        userManager.findId(email: email)
            .subscribe(onNext: { [weak self] isUsed in
                guard let self = self else { return }
                if isUsed {
                    showAlert.onNext(("사용 불가능", "이미 사용중인 아이디입니다."))
                    sendEmailResult.onNext(false)
                } else {
                    self.seconds = 181
                    showAlert.onNext(("인증 메일 발송", "인증 메일을 발송했습니다."))
                    setTimer()
                    sendEmail(email: email)
                    sendEmailResult.onNext(true)
                }
            }).disposed(by: disposeBag)
    }
    
    private func sendEmail(email: String) {
        SMTPManager.sendAuth(userEmail: email)
            .subscribe(onNext: { code in
                self.userAuthCode.onNext(code)
            }, onError: { error in
                self.showAlert.onNext(("이메일 발송 실패", "이메일 발송을 실패했습니다. 다시 시도해주세요."))
            })
            .disposed(by: disposeBag)
    }
    
    func checkAuthCode(code: String) {
        if code == (try? String(userAuthCode.value())) {
            showAlert.onNext(("인증 성공", "인증 성공했습니다."))
            timer?.invalidate()
            checkEmailAuthResult.onNext(true)
        } else {
            showAlert.onNext(("인증 실패", "인증 실패했습니다. 다시 시도해주세요."))
            checkEmailAuthResult.onNext(false)
        }
    }
    
    func checkNickname(nickname: String) {
        userManager.findNickname(nickname: nickname)
            .subscribe(
                onNext: { [weak self] user in
                    guard let self = self else { return }
                    if user != nil {
                        showAlert.onNext(("사용 불가능", "이미 사용중인 닉네임입니다."))
                        checkNicknameResult.onNext(false)
                    } else {
                        showAlert.onNext(("사용 가능", "사용 가능한 닉네임입니다. \n 입력하신 닉네임은 아이디 찾기시 이용됩니다."))
                        checkNicknameResult.onNext(true)
                    }
                },
                onError: { [weak self] error in
                    self?.showAlert.onNext(("오류", error.localizedDescription))
                }).disposed(by: disposeBag)
    }
    
    private func setTimer() {
        timer?.invalidate()
        userAuthCode.onNext(Int.random(in: 1...10000))
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            seconds -= 1
            
            if seconds > 0 {
                showTimer.onNext(self.seconds)
            } else {
                invalidTimer.onNext(())
                userAuthCode.onNext(Int.random(in: 1...10000))
            }
        }
    }
    
    func registerUser(email: String, nickname: String, password: String, checkPassword: String) {
        guard !email.isEmpty, !nickname.isEmpty, !password.isEmpty, !checkPassword.isEmpty else {
            showAlert.onNext(("입력 오류", "빈 필드가 있습니다. 모든 필드를 입력하세요."))
            return
        }
        
        guard
            (try? checkEmailAuthResult.value()) == true, (try? checkNicknameResult.value()) == true else {
            showAlert.onNext(("확인 필요", "이메일 인증과 닉네임 중복 확인을 완료해주세요."))
            return
        }
        
        guard validatePassword(password, checkPassword) != nil else { return }
        
        let newUser = User(email: email, nickname: nickname, isConnect: false, incomeCategory: ["💸 월급", "🐷 용돈", "💌 상여금"], expenditureCategory: ["🏡 생활비", "🍚 식비", "🚗 교통비"])
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                self.showAlert.onNext(("회원가입 실패", error.localizedDescription))
            } else {
                self.userManager.addUser(user: newUser)
                self.doneRegister.onNext(())
            }
        }
    }
    
    private func validatePassword(_ password: String, _ checkPassword: String) -> String? {
        guard password == checkPassword else {
            showAlert.onNext(("비밀번호 불일치", "비밀번호가 일치하지 않습니다."))
            return nil
        }
        
        guard password.isValidPassword() else {
            showAlert.onNext(("유효하지 않은 비밀번호", "비밀번호는 특수문자, 숫자 포함, 8자 이상이여야합니다."))
            return nil
        }
        return password
    }
    
    
}
