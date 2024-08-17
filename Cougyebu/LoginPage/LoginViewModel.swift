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
    var showAlert: PublishSubject<(String, String)> { get }
    var checkResult: PublishSubject<Bool> { get }
    
    func login(id: String, password: String)
    func findId(_ nickname: String)
    func maskEmail(email: String) -> String
}


// MARK: - LoginViewModel
class LoginViewModel: LoginProtocol {
    private let userManager = UserManager()
    
    let showAlert = PublishSubject<(String, String)>()
    let checkResult = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    
    func login(id: String, password: String) {
        guard !id.isEmpty, !password.isEmpty else {
            showAlert.onNext(("입력 필요", "아이디와 비밀번호를 입력하세요."))
            return
        }
        
        Auth.auth().signIn(withEmail: id, password: password) { [weak self] authResult, error in
            if let error = error {
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
    
    func findId(_ nickname: String) {
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

}


// MARK: - Extension
// String Extension으로 빼기 
extension LoginViewModel {
    func maskEmail(email: String) -> String {
        let components = email.components(separatedBy: "@")
        let firstPart = components[0] // @ 이전
        let secondPart = components[1] // @ 이후
        let maskLength = max(firstPart.count - 2, 0)
        let maskedFirstPart = String(firstPart.prefix(2) + String(repeating: "*", count: maskLength))
        
        return maskedFirstPart + "@" + secondPart
    }
}
