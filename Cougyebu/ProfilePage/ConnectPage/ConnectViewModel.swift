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
        userManager.disconnectUser(inputEmail: email){ [weak self] _ in
            guard let self = self else { return }
            observableUser?.value.coupleEmail = nil
            observableUser?.value.coupleNickname = nil
            observableUser?.value.requestUser = nil
            observableUser?.value.code = nil
            observableUser?.value.isConnect = false
            UserDefaults.standard.removeObject(forKey: "coupleNickname")
        }
    }
    
    func updateUser(email: String, updatedFields: [String: Any], completion: ((Bool?) -> Void)?) {
        userManager.updateUser(email: email, updatedFields: updatedFields) { bool in
            self.observableUser?.value.isConnect = true
        }
    }



   
}

