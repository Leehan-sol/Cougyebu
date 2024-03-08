//
//  ConnectViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation

class ConnectViewModel {

    private let fsManager = FirestoreManager()
    
    var observableUser: Observable<User>?
    
    init(observableUser:  Observable<User>) {
        self.observableUser = observableUser
    }
    
    func makeRandomNumber() -> String {
        let randomNumber = Int.random(in: 1000000..<9999999)
        let stringNumber = String(randomNumber)
        return stringNumber
    }
    
    func findId(email: String, completion: @escaping (Bool) -> Void) {
        fsManager.findId(email: email) { bool in
            completion(bool)
        }
    }
    
    func connectUser(email: String, code: String) {
        fsManager.connectUser(inputEmail: email, inputCode: code)
        observableUser?.value.coupleEmail = email
        observableUser?.value.code = code
    }


   
}

