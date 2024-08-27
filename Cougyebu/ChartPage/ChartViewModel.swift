//
//  ChartViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import Foundation

class ChartViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()
    
    var observableUser: Observable2<User>?
    var observablePost: Observable2<[Posts]> = Observable2<[Posts]>([])
    
    var userEmail: String
    var coupleEmail: String?
    var isConnect: Bool?
    private let currentDate = Date()
    lazy var allDatesInMonth: [String] = currentDate.getAllDatesInMonth()
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self.observableUser = Observable2<User>(User(email: "", nickname: "", isConnect: false))
    }
    
    func setUser() {
//        userManager.findUser(email: userEmail) { [self] user in
//            guard let user = user else { return }
//            self.observableUser?.value = user
//            self.coupleEmail = user.coupleEmail
//            self.isConnect = user.isConnect
//            self.loadPost(dates: allDatesInMonth)
//        }
    }
    
    func loadPost(dates: [String]) {
        var loadedPosts: [Posts] = []
        
//        for date in dates {
//            // 커플 이메일
//            if let coupleEmail = coupleEmail, isConnect == true {
//                postManager.loadPosts(email: coupleEmail, date: date) { [weak self] posts in
//                    if let post = posts {
//                        loadedPosts.append(contentsOf: post)
//                    }
//                    self?.observablePost.value = loadedPosts.sorted(by: { $0.date < $1.date }) // 데이터 갱신
//                    
//                }
//            }
//            // 사용자 이메일
//            postManager.loadPosts(email: userEmail, date: date) { [weak self] posts in
//                if let post = posts {
//                    loadedPosts.append(contentsOf: post)
//                }
//                self?.observablePost.value = loadedPosts.sorted(by: { $0.date < $1.date }) // 데이터 갱신
//            }
//        }
    }

}
