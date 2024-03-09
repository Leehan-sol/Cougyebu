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
    
    var observableUser: Observable<User>?
    var observablePost: Observable<[Posts]> = Observable([])
    
    var userEmail: String
    var userCategory: [String] = []
    var coupleEmail: String?
    var isConnect: Bool?

    init(userEmail: String) {
        self.userEmail = userEmail
        self.observableUser = Observable<User>(User(email: "", nickname: "", isConnect: false))
    }
    
    // user 세팅
    func setUser() {
        userManager.findUser(email: userEmail) { user in
            guard let user = user else { return }
            self.observableUser?.value = user
            self.coupleEmail = user.coupleEmail
            self.isConnect = user.isConnect
            
            if let coupleEmail = user.coupleEmail, user.isConnect == true {
                self.postManager.loadPosts(userEmail: coupleEmail, date: Date().toString(format: "yyyy.MM.dd")){ post in
                    guard let posts = post else { return }
                    self.observablePost.value.append(contentsOf: posts)
                }
            }
        }
    }
    
    
    func loadPost(email: String, date: String) {
        if let coupleEmail = coupleEmail, isConnect == true {
            self.postManager.loadPosts(userEmail: coupleEmail, date: date) { posts in
                guard let post = posts else { return }
                self.observablePost.value.append(contentsOf: post)
            }
        } else {
            self.observablePost.value = []
        }
        postManager.loadPosts(userEmail: email, date: date) { posts in
            if let post = posts {
                self.observablePost.value = post
            } else {
                self.observablePost.value = []
            }
        }
    }

    
    func addCost() -> Int {
        var totalCost = 0
        for post in observablePost.value {
            let costStringWithoutComma = post.cost.replacingOccurrences(of: ",", with: "")
            if let cost = Int(costStringWithoutComma) {
                totalCost += cost
            }
        }
        return totalCost
    }
    
    func loadCategory() {
        userManager.findCategory(email: userEmail){ category in
            guard let userCategory = category else { return }
            self.userCategory = userCategory
        }
    }
    
    
    
}
