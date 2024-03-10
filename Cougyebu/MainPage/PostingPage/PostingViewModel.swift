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
    var datesRange: [String]
    
    init(observablePost: Observable<[Posts]>, userEmail: String, userCategory: [String], datesRange: [String]) {
        self.observablePost = observablePost
        self.userEmail = userEmail
        self.userCategory = userCategory
        self.datesRange = datesRange
    }
    
    
    func addPost(date: String, posts: [Posts]) {
        postManager.addPost(email: userEmail, date: date, posts: posts)
        
        if datesRange.contains(date) {
            observablePost.value += posts
            observablePost.value = observablePost.value.sorted(by: { $0.date < $1.date })
        }
    }

    
    
}
