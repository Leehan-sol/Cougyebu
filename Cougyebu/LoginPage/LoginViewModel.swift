//
//  LoginViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/29.
//

import Foundation
import FirebaseAuth
import RxSwift

// MARK: - LoginProtocol
protocol LoginProtocol: AnyObject {
    func transform(input: LoginViewModel.Input) -> LoginViewModel.Output 
}

// MARK: - LoginViewModel
class LoginViewModel: LoginProtocol {
    private let userManager = UserManager()
    
    private let showAlert = PublishSubject<(String, String)>()
    private let checkResult = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let loginAction: PublishSubject<(String, String)>
        let findIdAction: PublishSubject<String>
    }
    
    struct Output {
        let showAlert: PublishSubject<(String, String)>
        let checkResult: PublishSubject<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.loginAction
            .bind(onNext: { id, pw in
                self.login(id: id, password: pw)
            }).disposed(by: disposeBag)
        
        input.findIdAction
            .bind(onNext: { nickname in
                self.findId(nickname: nickname)
            }).disposed(by: disposeBag)
        
        return Output(showAlert: showAlert,
                      checkResult: checkResult)
    }
    
    private func login(id: String, password: String) {
        guard !id.isEmpty, !password.isEmpty else {
            showAlert.onNext(("입력 필요", "아이디와 비밀번호를 입력하세요."))
            return
        }
        Auth.auth().signIn(withEmail: id, password: password) { [weak self] authResult, error in
            if error != nil {
                self?.showAlert.onNext(("로그인 실패", "아이디 또는 비밀번호가 틀렸습니다."))
                self?.checkResult.onNext(false)
            } else {
                self?.userManager.findId(email: id)
                    .subscribe(onNext: { exists in
                        if exists {
                            self?.checkResult.onNext(true)
                        } else {
                            self?.showAlert.onNext(("로그인 실패", "아이디 또는 비밀번호가 틀렸습니다."))
                            self?.checkResult.onNext(false)
                        }
                    }, onError: { error in
                        self?.showAlert.onNext(("아이디 찾기 실패", "오류가 발생했습니다."))
                        self?.checkResult.onNext(false)
                    }).disposed(by: self?.disposeBag ?? DisposeBag())
            }
        }
    }
    
    private func findId(nickname: String) {
        userManager.findNickname(nickname: nickname)
            .subscribe(onNext: { [weak self] user in
                if let user = user {
                    let alertTitle = "아이디 찾기 성공"
                    let alertMessage = self?.maskEmail(email: user.email) ?? ""
                    self?.showAlert.onNext((alertTitle, alertMessage))
                } else {
                    let alertTitle = "아이디 찾기 실패"
                    let alertMessage = "해당 닉네임을 가진 사용자를 찾을 수 없습니다."
                    self?.showAlert.onNext((alertTitle, alertMessage))
                }
            }, onError: { error in
                let alertTitle = "아이디 찾기 실패"
                let alertMessage = "오류가 발생했습니다."
                self.showAlert.onNext((alertTitle, alertMessage))
            }).disposed(by: disposeBag)
    }
    
    private func maskEmail(email: String) -> String {
        let components = email.components(separatedBy: "@")
        let firstPart = components[0] // @ 이전
        let secondPart = components[1] // @ 이후
        let maskLength = max(firstPart.count - 2, 0)
        let maskedFirstPart = String(firstPart.prefix(2) + String(repeating: "*", count: maskLength))
        
        return maskedFirstPart + "@" + secondPart
    }
    
}
