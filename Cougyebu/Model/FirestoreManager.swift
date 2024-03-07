//
//  FirestoreManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    
    // 유저 찾기
    func findUser(email: String, completion: @escaping (User?) -> Void) {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        query.getDocuments { (snapShot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let qs = snapShot, !qs.documents.isEmpty {
                if let data = qs.documents.first?.data() {
                    let email = data["email"] as? String ?? ""
                    let nickname = data["nickname"] as? String ?? ""
                    let isConnect = data["isConnect"] as? Bool ?? false
                    let code = data["level"] as? Int ?? 0
                    let coupleEmail = data["coupleEmail"] as? String ?? nil
                    let coupleNickname = data["coupleNickname"] as? String ?? nil
                    let postRef = data["postRef"] as? String? ?? nil
                    let user = User(email: email, nickname: nickname, isConnect: isConnect, code: code, coupleEmail: coupleEmail, coupleNickname: coupleNickname, postRef: postRef)
                    completion(user)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    // 닉네임 중복확인, 로직 수정
    func findNickname(nickname: String, completion: @escaping (User?) -> Void) {
        let userDB = db.collection("User")
        let query = userDB.whereField("nickname", isEqualTo: nickname)
        query.getDocuments { (snapShot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
            } else if let qs = snapShot, !qs.documents.isEmpty {
                if let data = qs.documents.first?.data() {
                    let email = data["email"] as? String ?? ""
                    let nickname = data["nickname"] as? String ?? ""
                    let isConnect = data["isConnect"] as? Bool ?? false
                    let user = User(email: email, nickname: nickname, isConnect: isConnect)
                    completion(user)
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    // 유저 생성
    func addUser(user: User) {
        db.collection("User").document(user.email).setData([
            "email": user.email,
            "nickname": user.nickname,
            "code": user.code as Any,
            "isConnect": user.isConnect as Any,
            "coupleEmail": user.coupleEmail as Any,
            "coupleNickname": user.coupleNickname as Any,
            "postRef": user.postRef as Any
        ]) { error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("유저생성 성공")
            }
        }
    }
   
    // 유저 업데이트
    func updateUser(email: String, updatedFields: [String: Any]) {
        db.collection("User").document(email).updateData(updatedFields) { error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("유저 정보 업데이트 성공")
            }
        }
    }
    
     
    // 유저 연결
    func connectUser(inputEmail: String, inputCode: Int) {
        db.collection("User").document(inputEmail).getDocument { [self] (document, error) in
            if let document = document, document.exists {
               // 입력한 사용자 데이터
                var updatedFields: [String: Any] = [:]
                updatedFields["coupleEmail"] = currentUser?.email
                updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
                updatedFields["isConnect"] = true
                updatedFields["code"] = inputCode
                
                updateUser(email: inputEmail, updatedFields: updatedFields)
                
                // 현재 사용자 데이터
                updatedFields["coupleEmail"] = inputEmail
                updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
                updatedFields["isConnect"] = true
                updatedFields["code"] = inputCode
                
                updateUser(email: (currentUser?.email)!, updatedFields: updatedFields)
                print("유저 연결 성공")
            } else {
                print("유저 연결 실패")
            }
        }
    }
    
    
    // 게시글 등록
    func addPost(email: String, post: Post) {
        db.collection(email).document(post.category).setData([
            "date": post.postingDate,
            "category": post.category,
            "content": post.content,
            "cost": post.cost
        ]) { error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("게시글생성 성공")
            }
        }
    }
    
}





