//
//  MyPageViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation

class MyPageViewModel {
    let headerData = ["엡 지원", "개인 / 보안"]
    let cellData = [["공지사항", "개인정보처리방침", "서비스이용약관", "문의하기"], ["커플 연결", "닉네임 변경", "로그아웃", "비밀번호 변경", "회원탈퇴"]]
    private let fsManager = FirestoreManager()
    
    var observableUser: Observable<User>?
    var userEmail: String?
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self.observableUser = Observable<User>(User(email: "", nickname: "", isConnect: false))
    }
    
    // observableUser 세팅
    func setUser() {
        guard let email = userEmail else { return }
        
        fsManager.findUser(email: email) { user in
            guard let user = user else { return }
            self.observableUser?.value = user
        }
    }
    
    
    
}
