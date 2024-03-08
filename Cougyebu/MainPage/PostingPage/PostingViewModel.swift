//
//  PostingViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation

class PostingViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()
    
    var observablePost: Observable<[Posts]>
    var userEmail: String
    
    init(observablePost: Observable<[Posts]>, userEmail: String) {
        self.observablePost = observablePost
        self.userEmail = userEmail
    }
    
    lazy var postCount = observablePost.value.count
    
    func loadPost(date: String) {
        postManager.loadPosts(userEmail: userEmail, date: date) { posts in
            guard let posts = posts else { return }
            self.observablePost.value = posts
        }
    }
    
    func addPost(date: String, posts: [Posts]) {
        postManager.addPost(email: userEmail, date: date, posts: posts)
        observablePost.value.append(contentsOf: posts)
    }
    
    
}
