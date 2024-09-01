//
//  PostManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import RxSwift

class PostManager {
    private let db = Firestore.firestore()
    
    // 게시글 로드
    func fetchLoadPosts(email: String, dates: [String]) -> Observable<[Posts]> {
        let apiCallObservables = dates.map { date -> Observable<[Posts]> in
            return loadPosts(email: email, date: date)
        }
        
        return Observable.zip(apiCallObservables)
            .map { results in
                return results.flatMap { $0 }
            }
    }
    
    func loadPosts(email: String, date: String) -> Observable<[Posts]> {
        let userDB = db.collection(email)
        let databaseRef = userDB.document(date)
        
        return Observable.create { observer in
            databaseRef.getDocument { snapshot, error in
                if let error = error {
                    print(error.localizedDescription)
                    observer.onNext([])
                } else if let snapshot = snapshot, snapshot.exists {
                    var posts: [Posts] = []
                    if let postData = snapshot.data()?["posts"] as? [[String: Any]] {
                        for data in postData {
                            if let date = data["date"] as? String,
                               let group = data["group"] as? String,
                               let category = data["category"] as? String,
                               let content = data["content"] as? String,
                               let cost = data["cost"] as? String,
                               let uuid = data["uuid"] as? String {
                                let post = Posts(date: date, group: group, category: category, content: content, cost: cost, uuid: uuid)
                                posts.append(post)
                            }
                        }
                    }
                    observer.onNext(posts)
                    observer.onCompleted()
                } else {
                    observer.onNext([])
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // 게시글 추가
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
    
    // 📌 게시글 수정
    func updatePost(email: String, originalDate: String, uuid: String, post: Posts, completion: ((Bool?) -> Void)?) {
//        let postDocRef = db.collection(email).document(originalDate)
//        
//        postDocRef.getDocument { snapshot, error in
//            if let error = error {
//                print("Error getting document: \(error)")
//                completion?(false)
//                return
//            }
//            
//            guard let snapshot = snapshot, snapshot.exists else {
//                print("Document does not exist")
//                completion?(false)
//                return
//            }
//            
//            let data = snapshot.data()
//            
//            if originalDate != post.date {
//                self.deletePost(email: email, date: originalDate, uuid: uuid) { success in
//                    if success! {
//                        print("Original document deleted successfully")
//                        self.addPost(email: email, date: post.date, post: post)
//                        completion?(true)
//                    } else {
//                        print("Error deleting original document")
//                        completion?(false)
//                    }
//                }
//            } else {
//                var posts = data?["posts"] as? [[String: Any]] ?? []
//                if let index = posts.firstIndex(where: { $0["uuid"] as? String == uuid }) {
//                    posts[index] = [
//                        "date": post.date,
//                        "group": post.group,
//                        "category": post.category,
//                        "content": post.content,
//                        "cost": post.cost,
//                        "uuid": post.uuid
//                    ]
//                } else {
//                    print("Post with UUID \(uuid) not found")
//                    completion?(false)
//                    return
//                }
//                
//                postDocRef.updateData(["posts": posts]) { error in
//                    if let error = error {
//                        print("Error updating document: \(error)")
//                        completion?(false)
//                    } else {
//                        print("Post successfully updated")
//                        completion?(true)
//                    }
//                }
//            }
//        }
    }
    
    // 게시글 삭제
    func deletePost(email: String, post: Posts) -> Observable<Bool> {
        let postDocRef = db.collection(email).document(post.date)
        
        return Observable.create { observer in
            postDocRef.getDocument { snapshot, error in
                if let error = error {
                    observer.onError(error)
                    return
                }

                guard let snapshot = snapshot, snapshot.exists else {
                    observer.onNext(false)
                    return
                }

                var posts = snapshot.data()?["posts"] as? [[String: Any]] ?? []
                if let index = posts.firstIndex(where: { $0["uuid"] as? String == post.uuid }) {
                    posts.remove(at: index)
                } else {
                    observer.onNext(false)
                    return
                }

                if posts.isEmpty {
                    postDocRef.delete { error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(true)
                            observer.onCompleted()
                        }
                    }
                } else {
                    postDocRef.updateData(["posts": posts]) { error in
                        if let error = error {
                            observer.onError(error)
                        } else {
                            observer.onNext(true)
                            observer.onCompleted()
                        }
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    // 📌 탈퇴시 게시글 전체 삭제
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
