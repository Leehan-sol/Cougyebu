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
                completion(nil)
                return
            }
            
            guard let data = snapshot.data(), let postsData = data["posts"] as? [[String: Any]] else {
                completion(nil)
                return
            }
            
            var posts: [Posts] = []
            for postData in postsData {
                if let date = postData["date"] as? String,
                   let group = postData["group"] as? String,
                   let category = postData["category"] as? String,
                   let content = postData["content"] as? String,
                   let cost = postData["cost"] as? String,
                   let uuid = postData["uuid"] as? String {
                    let post = Posts(date: date, group: group, category: category, content: content, cost: cost, uuid: uuid)
                    posts.append(post)
                } else {
                    print("Error parsing post data")
                }
            }
            
            completion(posts)
        }
    }
    

    func addPost(email: String, date: String, post: Posts) {
        let postData: [String: Any] = [
            "date": post.date,
            "group": post.group,
            "category": post.category,
            "content": post.content,
            "cost": post.cost,
            "uuid": post.uuid
        ]
        
        let postDocRef = db.collection(email).document(date)
        postDocRef.getDocument { (document, error) in
            if let document = document, document.exists {
                var existingPosts = document.data()?["posts"] as? [[String: Any]] ?? []
                existingPosts.append(postData)
                postDocRef.updateData(["posts": existingPosts]) { error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("게시글 추가 성공")
                    }
                }
            } else {
                postDocRef.setData(["posts": [postData]]) { error in
                    if let error = error {
                        print("Error: \(error)")
                    } else {
                        print("게시글 생성 성공")
                    }
                }
            }
        }
    }

    
    func updatePost(email: String, originalDate: String, uuid: String, post: Posts, completion: ((Bool?) -> Void)?) {
        let postDocRef = db.collection(email).document(originalDate)
        
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
            
            let data = snapshot.data()
            
            if originalDate != post.date {
                postDocRef.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                        completion?(false)
                    } else {
                        print("Original document deleted successfully")
                        self.addPost(email: email, date: post.date, post: post)
                        completion?(true)
                    }
                }
            } else {
                var posts = data?["posts"] as? [[String: Any]] ?? []
                if let index = posts.firstIndex(where: { $0["uuid"] as? String == uuid }) {
                    posts[index] = [
                        "date": post.date,
                        "group": post.group,
                        "category": post.category,
                        "content": post.content,
                        "cost": post.cost,
                        "uuid": post.uuid
                    ]
                } else {
                    print("Post with UUID \(uuid) not found")
                    completion?(false)
                    return
                }
                
                postDocRef.updateData(["posts": posts]) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        completion?(false)
                    } else {
                        print("Post successfully updated")
                        completion?(true)
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
            
            var posts = snapshot.data()?["posts"] as? [[String: Any]] ?? []
            if let index = posts.firstIndex(where: { $0["uuid"] as? String == uuid }) {
                posts.remove(at: index)
            } else {
                print("Post with UUID \(uuid) not found")
                completion?(false)
                return
            }
            
            if posts.isEmpty {
                postDocRef.delete { error in
                    if let error = error {
                        print("Error deleting document: \(error)")
                        completion?(false)
                    } else {
                        print("Document successfully deleted")
                        completion?(true)
                    }
                }
            } else {
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
    }
    
    
    
    func deleteAllPost(email: String, completion: ((Bool?) -> Void)?) {
        let userCollectionRef = db.collection(email)
        
        userCollectionRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion?(false)
                return
            }
            
            guard let snapshot = snapshot else {
                print("Snapshot is nil")
                completion?(false)
                return
            }
            
            for document in snapshot.documents {
                document.reference.delete()
                completion?(true)
                print("문서 삭제 성공")
            }
           
        }
    }
    
    
    
}
