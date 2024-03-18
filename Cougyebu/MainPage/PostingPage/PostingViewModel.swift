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
    var coupleEmail: String
    var userIncomeCategory: [String]
    var userExpenditureCategory: [String]
    var datesRange: [String]?
    var post: Posts?
    
    init(observablePost: Observable<[Posts]>, userEmail: String, coupleEmail: String, userIncomeCategory: [String], userExpenditureCategory: [String]) {
        self.observablePost = observablePost
        self.userEmail = userEmail
        self.coupleEmail = coupleEmail
        self.userIncomeCategory = userIncomeCategory
        self.userExpenditureCategory = userExpenditureCategory
    }
    
    
    func addPost(date: String, posts: Posts) {
        postManager.addPost(email: userEmail, date: date, post: posts)
        
        guard let range = datesRange else { return }
        
        if range.contains(date) {
            observablePost.value += [posts]
            observablePost.value = observablePost.value.sorted(by: { $0.date < $1.date })
        }
        
    }
    
    func updatePost(originalDate: String, uuid: String, post: Posts, completion: ((Bool?) -> Void)?) {
        postManager.updatePost(email: userEmail, originalDate: originalDate, uuid: uuid, post: post) { [weak self] bool in
            if bool == true {
                completion?(true)
            } else {
                guard let self = self else { return }
                self.postManager.updatePost(email: coupleEmail, originalDate: originalDate, uuid: uuid, post: post) { bool in
                    if bool == true {
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            }
        }
    }
    
    
}
