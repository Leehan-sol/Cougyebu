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
//    func loadPost(email: String, date: String, completion: @escaping ([Posts]?) -> Void) {
//        let userDB = db.collection(email)
//        let query = userDB.whereField("date", isEqualTo: date)
//        
//        query.getDocuments { (snapshot, error) in
//            if let error = error {
//                print(error.localizedDescription)
//                return
//            }
//            
//            guard let snapshot = snapshot, !snapshot.isEmpty else { return }
//            guard let data = snapshot.documents.first?.data() else { return }
//            
//            var posts: [Posts] = []
//            
//            for document in snapshot.documents {
//                let date = data["date"] as? String ?? ""
//                let category = data["category"] as? String ?? ""
//                let content = data["content"] as? String ?? ""
//                let cost = data["cost"] as? Int ?? 0
//                
//                let post = Posts(date: date, posts: [])
//                posts.append(post)
//            }
//            completion(posts)
//            print(posts)
//        }
//    }
    
    
    
    // 게시글 등록
    func addPost(email: String, date: String, posts: [Posts]) {
        var postsData: [[String: Any]] = []
        for post in posts {
            let postData: [String: Any] = [
                "date": post.date,
                "category": post.category,
                "content": post.content,
                "cost": post.cost
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

    
    
}
