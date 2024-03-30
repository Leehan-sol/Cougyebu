//
//  LoginViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/29.
//

import Combine
import Foundation
import FirebaseAuth

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
    
    
    
}

