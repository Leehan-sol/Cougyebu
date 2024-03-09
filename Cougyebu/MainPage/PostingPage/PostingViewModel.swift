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
    var userCategory: [String]
    
    init(observablePost: Observable<[Posts]>, userEmail: String, userCategory: [String]) {
        self.observablePost = observablePost
        self.userEmail = userEmail
        self.userCategory = userCategory
    }


    func addPost(date: String, posts: [Posts]) {
        postManager.addPost(email: userEmail, date: date, posts: posts)
        // ✨ mainView에서 날짜 받아와서 date가 맞아야 포함시키기
       // observablePost.value.append(contentsOf: posts)
    }
    
    
}
