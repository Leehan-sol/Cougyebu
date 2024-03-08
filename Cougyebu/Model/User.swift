//
//  User.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation

struct User {
    var email: String
    var nickname: String
    var isConnect: Bool
    var code: String?
    var coupleEmail: String?
    var coupleNickname: String?
    var postRef: String?// 데이터 가져와서 Post 배열로 변경해서 사용
}

