//
//  FirestoreManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RxSwift

class UserManager {
    private let db = Firestore.firestore()
    private let currentUser = Auth.auth().currentUser
    
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
    
    func findUser(email: String) -> Observable<User?> {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        return Observable.create { observer in
            query.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let snapshot = snapshot, let data = snapshot.documents.first?.data() else {
                    observer.onNext(nil)
                    observer.onCompleted()
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
                
                if let coupleNicknameRef = data["coupleNickname"] as? DocumentReference {
                    coupleNicknameRef.getDocument { coupleSnapshot, error in
                        if let error = error {
                            observer.onError(error)
                            return
                        }
                        
                        let coupleNickname = coupleSnapshot?.data()?["nickname"] as? String
                        let user = User(email: email,
                            nickname: nickname,
                            isConnect: isConnect,
                            code: code,
                            coupleEmail: coupleEmail,
                            coupleNickname: coupleNickname,
                            requestUser: requestUser,
                            incomeCategory: incomeCategory,
                            expenditureCategory: expenditureCategory
                        )
                        observer.onNext(user)
                        observer.onCompleted()
                    }
                } else {
                    let user = User(
                        email: email,
                        nickname: nickname,
                        isConnect: isConnect,
                        code: code,
                        coupleEmail: coupleEmail,
                        coupleNickname: nil,
                        requestUser: requestUser,
                        incomeCategory: incomeCategory,
                        expenditureCategory: expenditureCategory
                    )
                    observer.onNext(user)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func findId(email: String) -> Observable<Bool> {
        let userDB = db.collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        return Observable.create { observer in
            query.getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    observer.onNext(true)
                    observer.onCompleted()
                } else {
                    observer.onNext(false)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func findNickname(nickname: String) -> Observable<User?> {
        let userDB = db.collection("User")
        let query = userDB.whereField("nickname", isEqualTo: nickname)
        
        return Observable.create { observer in
            query.getDocuments { snapshot, error in
                if let error = error {
                    observer.onError(error)
                } else if let snapshot = snapshot, !snapshot.documents.isEmpty {
                    guard let data = snapshot.documents.first?.data() else {
                        observer.onNext(nil)
                        observer.onCompleted()
                        return
                    }
                    let email = data["email"] as? String ?? ""
                    let nickname = data["nickname"] as? String ?? ""
                    let isConnect = data["isConnect"] as? Bool ?? false
                    let user = User(email: email, nickname: nickname, isConnect: isConnect)
                    observer.onNext(user)
                    observer.onCompleted()
                } else {
                    observer.onNext(nil)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    func findCategory(email: String) -> Observable<([String], [String])> {
        let userDB = Firestore.firestore().collection("User")
        let query = userDB.whereField("email", isEqualTo: email)
        
        return Observable.create { observer in
            query.getDocuments { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onError(error)
                    return
                }
                
                if let snapshot = snapshot, !snapshot.isEmpty {
                    guard let data = snapshot.documents.first?.data() else {
                        observer.onNext(([], []))
                        observer.onCompleted()
                        return
                    }
                    
                    let incomeCategory = data["incomeCategory"] as? [String] ?? []
                    let expenditureCategory = data["expenditureCategory"] as? [String] ?? []
                    observer.onNext((incomeCategory, expenditureCategory))
                    observer.onCompleted()
                } else {
                    observer.onNext(([], []))
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // 📌 유저 업데이트
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
    
    // 📌 유저닉네임 업데이트
    func updateUserNickname(email: String, updatedFields: [String: Any]) -> Observable<Bool> {
        return Observable.create { observer in
            self.db.collection("User").document(email).updateData(updatedFields) { error in
                if let error = error {
                    print("Error: \(error)")
                    observer.onError(error)
                } else {
                    print("유저 정보 업데이트 성공")
                    observer.onNext(true)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // 유저 삭제
    func deleteUser(email: String) {
        db.collection("User").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            for document in querySnapshot!.documents {
                document.reference.delete()
                print("유저 문서 삭제 성공")
            }
        }
        UserDefaults.standard.removeObject(forKey: "coupleNickname")
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
    
    // 📌 유저 연결 해제
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

