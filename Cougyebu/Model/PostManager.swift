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
    func loadPosts(userEmail: String, date: String, completion: @escaping ([Posts]?) -> Void) {
        let userDB = db.collection(userEmail)
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
    
    
    
}
