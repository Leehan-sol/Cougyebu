//
//  LoginViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/29.
//

import Combine
import Foundation
import FirebaseAuth

protocol LoginViewProtocol: AnyObject {
    var checkResult: PassthroughSubject<String?, Never> { get }
    var id: String { get set }
    var password: String { get set }
    
    func loginButtonTapped()
    func findIdByNickname(_ nickname: String, completion: @escaping (User?) -> Void)
    func maskEmail(email: String) -> String
}

class LoginViewModel {
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
    
    func findIdByNickname(_ nickname: String, completion: @escaping ((User?) -> Void)) {
        userManager.findNickname(nickname: nickname) { findUser in
            if let user = findUser {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
    
    func maskEmail(email: String) -> String {
        let components = email.components(separatedBy: "@")
        let firstPart = components[0] // @ 이전
        print(firstPart)
        let secondPart = components[1] // @ 이후
        print(secondPart)
        let maskLength = max(firstPart.count - 2, 0)
        let maskedFirstPart = String(firstPart.prefix(2) + String(repeating: "*", count: maskLength))

        return maskedFirstPart + "@" + secondPart
    }
    
}

