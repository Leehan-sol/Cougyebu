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
                    let code = data["code"] as? String ?? nil
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
    
    // 아이디 찾기
    func findId(email: String, completion: @escaping (Bool) -> Void) {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        query.getDocuments { (snapShot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
            } else if let qs = snapShot, !qs.documents.isEmpty {
                completion(true)
            } else {
                completion(false)
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
    
    // 유저 삭제
    func deleteUser(user: FirebaseAuth.User){
        if let email = user.email {
            db.collection("User").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
     
    // 유저 연결
//    func connectUser(inputEmail: String, inputCode: String) {
//        db.collection("User").document(inputEmail).getDocument { [self] (document, error) in
//            guard let document = document, document.exists else { return }
//            if let code = document["code"] as? String, code == inputCode {
//                // 입력한 사용자 데이터
//                var updatedFields: [String: Any] = [:]
//                updatedFields["coupleEmail"] = currentUser?.email
//                updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
//                updatedFields["isConnect"] = true
//                updatedFields["code"] = inputCode
//
//                updateUser(email: inputEmail, updatedFields: updatedFields)
//
//                // 현재 사용자 데이터
//                updatedFields["coupleEmail"] = inputEmail
//                updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
//                updatedFields["isConnect"] = true
//                updatedFields["code"] = inputCode
//
//                updateUser(email: (currentUser?.email)!, updatedFields: updatedFields)
//                print("유저 연결 성공")
//            } else {
//                // 얼랏 띄우기
//                print("유저 연결 실패")
//            }
//        }
//    }

    func connectUser(inputEmail: String, inputCode: String) {
        db.collection("User").document(inputEmail).getDocument { [self] (document, error) in
            guard let document = document, document.exists else { return }
            
            if let code = document["code"] as? String {
                // 코드 o
                handleExistingCode(inputEmail: inputEmail, inputCode: inputCode, storedCode: code)
            } else {
                // 코드 x
                handleMissingCode(inputEmail: inputEmail, inputCode: inputCode)
            }
        }
    }
    
    func handleExistingCode(inputEmail: String, inputCode: String, storedCode: String) {
        if storedCode == inputCode {
            // 입력한 사용자 데이터
            var updatedFields: [String: Any] = [:]
            updatedFields["coupleEmail"] = currentUser?.email
            updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
//            updatedFields["isConnect"] = true
            updatedFields["code"] = inputCode
            
            updateUser(email: inputEmail, updatedFields: updatedFields)
            
            // 현재 사용자 데이터
            updatedFields["coupleEmail"] = inputEmail
            updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
//            updatedFields["isConnect"] = true
            updatedFields["code"] = inputCode
            
            updateUser(email: (currentUser?.email)!, updatedFields: updatedFields)
            print("유저 연결 성공")
        } else {
            // 입력한 코드와 일치하지 않는 경우
            print("유저 연결 실패: 코드가 일치하지 않습니다")
        }
    }

    func handleMissingCode(inputEmail: String, inputCode: String) {
        // 입력한 사용자 데이터
        var updatedFields: [String: Any] = [:]
        updatedFields["coupleEmail"] = currentUser?.email
        updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
        updatedFields["code"] = inputCode
        
        updateUser(email: inputEmail, updatedFields: updatedFields)
        
        // 현재 사용자 데이터
        updatedFields["coupleEmail"] = inputEmail
        updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
        updatedFields["code"] = inputCode
        
        updateUser(email: (currentUser?.email)!, updatedFields: updatedFields)
        print("유저 연결 성공: 코드가 생성되었습니다")
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

