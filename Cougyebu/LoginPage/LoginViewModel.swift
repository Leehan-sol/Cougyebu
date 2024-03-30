//
//  LoginViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/29.
//

import Combine
import Foundation
import FirebaseAuth

// MARK: - LoginViewProtocol
protocol LoginViewProtocol: AnyObject {
    var checkResult: PassthroughSubject<String?, Never> { get }
    var id: String { get set }
    var password: String { get set }
    
    func loginButtonTapped()
    func findNickname(_ nickname: String) -> AnyPublisher<User?, Error>
    func maskEmail(email: String) -> String
}


// MARK: - LoginViewModel
class LoginViewModel: LoginViewProtocol {
    private let userManager = UserManager()
    let checkResult = PassthroughSubject<String?, Never>()
    @Published var id = ""
    @Published var password = ""
    
    
    func loginButtonTapped() {
        Auth.auth().signIn(withEmail: id, password: password) { [self] authResult, error in
            if error != nil {
                self.checkResult.send(nil)
            } else {
                self.userManager.findId(email: id) { bool in
                    if bool {
                        self.checkResult.send(self.id)
                    } else {
                        self.checkResult.send(nil)
                    }
                }
            }
        }
    }
    
    func findNickname(_ nickname: String) -> AnyPublisher<User?, Error> {
        return userManager.findIdByNickname(nickname: nickname)
            .eraseToAnyPublisher()
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

