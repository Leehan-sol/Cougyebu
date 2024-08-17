//
//  ConnectViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation
import RxSwift

class ConnectViewModel {

    private let userManager = UserManager()
    private let disposeBag = DisposeBag()
    
    var observableUser: Observable2<User>?
    
    init(observableUser:  Observable2<User>) {
        self.observableUser = observableUser
    }
    
    func makeRandomNumber() -> String {
        let randomNumber = Int.random(in: 1000000..<9999999)
        let stringNumber = String(randomNumber)
        return stringNumber
    }
    
    func findId(email: String, completion: @escaping (Bool) -> Void) {
        userManager.findId(email: email)
            .subscribe(onNext: { exists in
                completion(exists)
            }).disposed(by: disposeBag)
    }
    
    func connectUser(email: String, code: String, request: Bool) {
        userManager.connectUser(inputEmail: email, inputCode: code)
        observableUser?.value.coupleEmail = email
        observableUser?.value.code = code
        observableUser?.value.requestUser = request
    }
    
    func disconnectUser(email: String) {
        userManager.disconnectUser(inputEmail: email){ _ in
            self.observableUser?.value.coupleEmail = nil
            self.observableUser?.value.coupleNickname = nil
            self.observableUser?.value.requestUser = nil
            self.observableUser?.value.code = nil
            self.observableUser?.value.isConnect = false
        }
    }
    
    func updateUser(email: String, updatedFields: [String: Any], completion: ((Bool?) -> Void)?) {
        userManager.updateUser(email: email, updatedFields: updatedFields) { bool in
            self.observableUser?.value.isConnect = true
        }
    }



   
}

