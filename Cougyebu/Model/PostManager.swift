//
//  PostManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class PostManager {
    private let db = Firestore.firestore()
    
    // 게시글 로드
    func loadPosts(email: String, date: String, completion: @escaping ([Posts]?) -> Void) {
        let userDB = db.collection(email)
        let databaseRef = userDB.document(date)
        
        databaseRef.getDocument { snapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Document does not exist")
                completion(nil)
                return
            }
            
            guard let data = snapshot.data(), let postsData = data["posts"] as? [[String: Any]] else {
                print("Posts data is missing or not in expected format")
                completion(nil)
                return
            }
            
            var posts: [Posts] = []
            for postData in postsData {
                if let date = postData["date"] as? String,
                   let category = postData["category"] as? String,
                   let content = postData["content"] as? String,
                   let cost = postData["cost"] as? String,
                   let uuid = postData["uuid"] as? String {
                    let post = Posts(date: date, category: category, content: content, cost: cost, uuid: uuid)
                    posts.append(post)
                } else {
                    print("Error parsing post data")
                }
            }
            
            completion(posts)
        }
    }
    
    
    
    // 게시글 등록
    func addPost(email: String, date: String, posts: [Posts]) {
        var postsData: [[String: Any]] = []
        for post in posts {
            let postData: [String: Any] = [
                "date": post.date,
                "category": post.category,
                "content": post.content,
                "cost": post.cost,
                "uuid": post.uuid
            ]
            postsData.append(postData)
        }
        
        let postDocRef = db.collection(email).document(date)
        postDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // 기존 데이터가 있는 경우
                var existingPosts = document.data()?["posts"] as? [[String: Any]] ?? []
                existingPosts.append(contentsOf: postsData)
                postDocRef.updateData(["posts": existingPosts]) { error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("게시글 추가 성공")
                    }
                }
            } else {
                // 새로운 문서를 생성하여 데이터 추가
                postDocRef.setData(["posts": postsData]) { error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("게시글 생성 성공")
                    }
                }
            }
        }
    }
    
    func deletePost(email: String, date: String, uuid: String, completion: ((Bool?) -> Void)?) {
        let postDocRef = db.collection(email).document(date)
        
        postDocRef.getDocument { snapshot, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion?(false)
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists else {
                print("Document does not exist")
                completion?(false)
                return
            }
            
            // 문서가 존재하면 해당 문서의 "posts" 필드를 가져옴
            var posts = snapshot.data()?["posts"] as? [[String: Any]] ?? []
            
            // uuid가 같은 데이터를 찾아서 삭제
            if let index = posts.firstIndex(where: { $0["uuid"] as? String == uuid }) {
                posts.remove(at: index)
            } else {
                // 해당 uuid를 가진 데이터를 찾지 못한 경우
                print("Post with UUID \(uuid) not found")
                completion?(false)
                return
            }
            
            // 업데이트된 데이터로 문서 업데이트
            postDocRef.updateData(["posts": posts]) { error in
                if let error = error {
                    print("Error updating document: \(error)")
                    completion?(false)
                } else {
                    print("Post successfully deleted")
                    completion?(true)
                }
            }
        }
    }


    
//    func deleteCategory(email: String, category: String) {
//        let userDB = db.collection("User")
//        let query = userDB.whereField("email", isEqualTo: email)
//        
//        query.getDocuments { (snapshot, error) in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            if let snapshot = snapshot, !snapshot.isEmpty {
//                for document in snapshot.documents {
//                    var categories = document.data()["category"] as? [String] ?? []
//                    // 카테고리에서 삭제할 항목을 찾아서 제거
//                    categories.removeAll { $0 == category }
//                    // 업데이트된 카테고리 정보로 사용자 업데이트
//                    self.updateUser(email: email, updatedFields: ["category": categories]) { success in
//                        if let success = success, success {
//                            print("사용자 카테고리 삭제 성공")
//                        } else {
//                            print("사용자 카테고리 삭제 실패")
//                        }
//                    }
//                }
//            }
//        }
//    }
    
}
