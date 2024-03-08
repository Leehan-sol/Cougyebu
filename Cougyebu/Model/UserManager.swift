//
//  FirestoreManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class UserManager {
    
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    
    // 유저 찾기
    func findUser(email: String, completion: @escaping (User?) -> Void) {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else { return }
            guard let data = snapshot.documents.first?.data() else { return }
            
            let email = data["email"] as? String ?? ""
            let nickname = data["nickname"] as? String ?? ""
            let isConnect = data["isConnect"] as? Bool ?? false
            let code = data["code"] as? String
            let coupleEmail = data["coupleEmail"] as? String
            let requestUser = data["requestUser"] as? Bool
            
            // 커플 닉네임 가져오기
            var coupleNickname: String?
            if let coupleNicknameRef = data["coupleNickname"] as? DocumentReference {
                coupleNicknameRef.getDocument { (snapshot, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
                    
                    guard let snapshot = snapshot, let data = snapshot.data() else {
                        completion(nil)
                        return
                    }
                    
                    coupleNickname = data["nickname"] as? String
                    let user = User(email: email, nickname: nickname, isConnect: isConnect, code: code, coupleEmail: coupleEmail, coupleNickname: coupleNickname, requestUser: requestUser)
                    completion(user)
                }
            } else {
                let user = User(email: email, nickname: nickname, isConnect: isConnect, code: code, coupleEmail: coupleEmail, coupleNickname: nil, requestUser: requestUser)
                completion(user)
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
    
    // 닉네임 중복확인
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
        ]) { error in
            if let error = error {
                print("Error: \(error)")
            } else {
                print("유저생성 성공")
            }
        }
    }
    
    // 유저 업데이트
    func updateUser(email: String, updatedFields: [String: Any], completion: ((Bool?) -> Void)?) {
        db.collection("User").document(email).updateData(updatedFields) { error in
            if let error = error {
                print("Error: \(error)")
                completion?(false)
            } else {
                print("유저 정보 업데이트 성공")
                completion?(true)
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
    
    // 유저 연결 (inputEmail: 상대이메일)
    func connectUser(inputEmail: String, inputCode: String) {
        db.collection("User").document(inputEmail).getDocument { [self] (document, error) in
            guard let document = document, document.exists else { return }
            // 코드가 있고, 일치하는 경우
            if let code = document["code"] as? String, code == inputCode {
                // 상대 데이터
                var updatedFields: [String: Any] = [:]
                updatedFields["coupleEmail"] = currentUser?.email
                updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
                updatedFields["code"] = inputCode
                updatedFields["isConnect"] = true
                updateUser(email: inputEmail, updatedFields: updatedFields){ _ in }
                
                // 내 데이터
                updatedFields["coupleEmail"] = inputEmail
                updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
                updatedFields["isConnect"] = true
                updatedFields["code"] = inputCode
                updateUser(email: (currentUser?.email)!, updatedFields: updatedFields){ _ in }
                print("유저 연결 성공, true")
            } else {
                // 코드가 없는 경우 그냥 저장
                // 상대데이터
                var updatedFields: [String: Any] = [:]
                updatedFields["coupleEmail"] = currentUser?.email
                updatedFields["coupleNickname"] = db.collection("User").document((currentUser?.email)!)
                updatedFields["code"] = inputCode
                updatedFields["requestUser"] = false
                updateUser(email: inputEmail, updatedFields: updatedFields){ bool in
                    
                }
                // 내 데이터
                updatedFields["coupleEmail"] = inputEmail
                updatedFields["coupleNickname"] = db.collection("User").document(inputEmail)
                updatedFields["code"] = inputCode
                updatedFields["requestUser"] = true
                updateUser(email: (currentUser?.email)!, updatedFields: updatedFields){ bool in }
                print("유저 연결 성공, false")
            }
        }
    }
    
    // 유저 연결 해제
    func disconnectUser(inputEmail: String, completion: ((Bool?) -> Void)?) {
        db.collection("User").document(inputEmail).getDocument { [self] (document, error) in
            guard let document = document, document.exists else {
                completion?(false)
                return
            }
            // 내 데이터
            var updatedFields: [String: Any] = [:]
            updatedFields["coupleEmail"] = FieldValue.delete()
            updatedFields["coupleNickname"] = FieldValue.delete()
            updatedFields["code"] = FieldValue.delete()
            updatedFields["requestUser"] = FieldValue.delete()
            updatedFields["isConnect"] = false
            updateUser(email: inputEmail, updatedFields: updatedFields) { _ in }
            
            // 상대 데이터
            updatedFields["coupleEmail"] = FieldValue.delete()
            updatedFields["coupleNickname"] = FieldValue.delete()
            updatedFields["code"] = FieldValue.delete()
            updatedFields["requestUser"] = FieldValue.delete()
            updatedFields["isConnect"] = false
            updateUser(email: currentUser?.email ?? "", updatedFields: updatedFields) { _ in
                completion?(true)
                print("유저 연결 해제")
            }
        }
    }

    
}

