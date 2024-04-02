//
//  LoginViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/29.
//

import Foundation
import Combine
import FirebaseAuth

// MARK: - LoginViewProtocol
protocol LoginViewProtocol: AnyObject {
    var checkResult: PassthroughSubject<String?, Never> { get }
    var showAlert: PassthroughSubject<(String, String), Never> { get }
    
    func loginButtonTapped(id: String, password: String)
    func findId(_ nickname: String)
    func maskEmail(email: String) -> String
}


// MARK: - LoginViewModel
class LoginViewModel: LoginViewProtocol {
    
    private let userManager = UserManager()
    
    let showAlert = PassthroughSubject<(String, String), Never>()
    let checkResult = PassthroughSubject<String?, Never>()
    private var cancelBags = Set<AnyCancellable>()
    
    
    func loginButtonTapped(id: String, password: String) {
        guard !id.isEmpty, !password.isEmpty else {
            showAlert.send(("입력 필요", "아이디와 비밀번호를 입력하세요."))
            return
        }
        
        Auth.auth().signIn(withEmail: id, password: password) { [self] authResult, error in
            if error != nil {
                self.checkResult.send(nil)
                self.showAlert.send(("로그인 실패", "아이디 또는 비밀번호가 틀렸습니다."))
            } else {
                self.userManager.findId(email: id) { bool in
                    if bool {
                        self.checkResult.send(id)
                    } else {
                        self.checkResult.send(nil)
                        self.showAlert.send(("로그인 실패", "아이디 또는 비밀번호가 틀렸습니다."))
                    }
                }
            }
        }
    }
    
    func findId(_ nickname: String) {
        // 기존작업 취소, 삭제 // dataRace 방지
        cancelBags.forEach { $0.cancel() }
        cancelBags.removeAll()
        
           userManager.findIdByNickname(nickname: nickname)
               .sink(receiveCompletion: { [weak self] completion in
                   switch completion {
                   case .finished:
                       break
                   case .failure(_):
                       self?.showAlert.send(("아이디 찾기 실패", "아이디를 찾는 도중 오류가 발생했습니다."))
                   }
               }, receiveValue: { [weak self] user in
                   var alertTitle: String
                   var alertMessage: String
                   
                   if let user = user {
                       alertTitle = "아이디 찾기 성공"
                       alertMessage = self?.maskEmail(email: user.email) ?? ""
                   } else {
                       alertTitle = "아이디 찾기 실패"
                       alertMessage = "해당 닉네임을 가진 사용자를 찾을 수 없습니다."
                   }
                   self?.showAlert.send((alertTitle, alertMessage))
               })
               .store(in: &cancelBags)
       }
       
    
    
    func maskEmail(email: String) -> String {
        let components = email.components(separatedBy: "@")
        let firstPart = components[0] // @ 이전
        let secondPart = components[1] // @ 이후
        let maskLength = max(firstPart.count - 2, 0)
        let maskedFirstPart = String(firstPart.prefix(2) + String(repeating: "*", count: maskLength))

        return maskedFirstPart + "@" + secondPart
    }
    
}

