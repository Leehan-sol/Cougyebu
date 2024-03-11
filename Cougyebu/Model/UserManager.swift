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
                completion(nil)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                guard let data = snapshot.documents.first?.data() else {
                    completion(nil)
                    return
                }
                
                let email = data["email"] as? String ?? ""
                let nickname = data["nickname"] as? String ?? ""
                let isConnect = data["isConnect"] as? Bool ?? false
                let code = data["code"] as? String
                let coupleEmail = data["coupleEmail"] as? String
                let requestUser = data["requestUser"] as? Bool
                let incomeCategory = data["incomeCategory"] as? [String]
                let expenditureCategory = data["expenditureCategory"] as? [String]
                
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
                        let user = User(email: email, nickname: nickname, isConnect: isConnect, code: code, coupleEmail: coupleEmail, coupleNickname: coupleNickname, requestUser: requestUser, incomeCategory: incomeCategory, expenditureCategory: expenditureCategory)
                        completion(user)
                    }
                } else {
                    let user = User(email: email, nickname: nickname, isConnect: isConnect, code: code, coupleEmail: coupleEmail, coupleNickname: nil, requestUser: requestUser, incomeCategory: incomeCategory, expenditureCategory: expenditureCategory)
                    completion(user)
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
    
    
    // 닉네임 찾기
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
    
    
    // 카테고리 찾기
    func findCategory(email: String, completion: @escaping (([String]?, [String]?) -> Void)) {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                completion(nil, nil)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                guard let data = snapshot.documents.first?.data() else {
                    completion(nil, nil)
                    return
                }
                
                let incomeCategory = data["incomeCategory"] as? [String]
                let expenditureCategory = data["expenditureCategory"] as? [String]
                completion(incomeCategory, expenditureCategory)
            } else {
                completion(nil, nil)
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
            "incomeCategory": user.incomeCategory as Any,
            "expenditureCategory": user.expenditureCategory as Any
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
    
    
    // 카테고리 추가
    func addCategory(email: String?, category: String, categoryType: String) {
        guard let email = email else { return }
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                guard let document = snapshot.documents.first else { return }
                
                var updatedData = document.data()
                var currentCategories: [String]
                if categoryType == "income" {
                    currentCategories = updatedData["incomeCategory"] as? [String] ?? []
                } else {
                    currentCategories = updatedData["expenditureCategory"] as? [String] ?? []
                }
                currentCategories.append(category)
                
                if categoryType == "income" {
                    updatedData["incomeCategory"] = currentCategories
                } else {
                    updatedData["expenditureCategory"] = currentCategories
                }
                
                document.reference.setData(updatedData) { error in
                    if let error = error {
                        print("Error adding category: \(error.localizedDescription)")
                    } else {
                        print("Category added successfully.")
                    }
                }
            }
        }
    }

    
    // 카테고리 삭제
    func deleteCategory(email: String, category: String, categoryType: String) {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot, !snapshot.isEmpty {
                for document in snapshot.documents {
                    var categories: [String] = []
                    if categoryType == "income" {
                        categories = document.data()["incomeCategory"] as? [String] ?? []
                    } else {
                        categories = document.data()["expenditureCategory"] as? [String] ?? []
                    }
                    
                    categories.removeAll { $0 == category }
                    
                    var updatedFields: [String: Any] = [:]
                    if categoryType == "income" {
                        updatedFields["incomeCategory"] = categories
                    } else {
                        updatedFields["expenditureCategory"] = categories
                    }
                    
                    self.updateUser(email: email, updatedFields: updatedFields) { success in
                        if let success = success, success {
                            print("사용자 카테고리 삭제 성공")
                        } else {
                            print("사용자 카테고리 삭제 실패")
                        }
                    }
                }
            }
        }
    }

    
}

