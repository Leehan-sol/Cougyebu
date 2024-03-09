//
//  MainViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation

class MainViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()

    
    var observablePost: Observable<[Posts]> = Observable([])
    var userEmail: String
    var userCategory: [String] = []
    
    init(userEmail: String) {
        self.userEmail = userEmail
    }
    
    lazy var postCount = observablePost.value.count
    
    func loadPost(date: String) {
        postManager.loadPosts(userEmail: userEmail, date: date) { posts in
            guard let posts = posts else { return }
            // ✨ 날짜 일치할때만 추가로 변경 
            self.observablePost.value = posts
        }
    }
    
    func loadCategory() {
        userManager.findCategory(email: userEmail){ category in
            guard let userCategory = category else { return }
            self.userCategory = userCategory
        }
     }
    

    
}
