//
//  ChartViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/11.
//

import Foundation
import RxSwift

class ChartViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()
    private let disposeBag = DisposeBag()
    
    var observableUser: Observable2<User>?
    var observablePost: Observable2<[Post]> = Observable2<[Post]>([])
    
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
        userManager.findUser(email: userEmail)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                if let user = user {
                    observableUser?.value = user
                    coupleEmail = user.coupleEmail
                    isConnect = user.isConnect
                    loadPost(dates: allDatesInMonth)
                }
            }).disposed(by: disposeBag)
    }
    
    func loadPost(dates: [String]) {
        if let user = observableUser?.value, let coupleEmail = user.coupleEmail, user.isConnect == true  {
            print(user, coupleEmail)
            let coupleEmailPosts = postManager.fetchLoadPosts(email: coupleEmail, dates: dates)
            let userEmailPosts = postManager.fetchLoadPosts(email: userEmail, dates: dates)
            
            Observable.zip(coupleEmailPosts, userEmailPosts)
                .map { couplePosts, myPosts in
                    return (couplePosts + myPosts).sorted { $0.date < $1.date }
                }
                .subscribe(onNext: { [weak self] sortedPosts in
                    guard let self = self else { return }
                    observablePost.value = sortedPosts
                }).disposed(by: disposeBag)
        } else {
            postManager.fetchLoadPosts(email: userEmail, dates: dates)
                .map { posts in
                    return posts.sorted { $0.date < $1.date }
                }
                .subscribe(onNext: { [weak self] sortedPosts in
                    guard let self = self else { return
                    }
                    observablePost.value = sortedPosts
                }).disposed(by: disposeBag)
        }
    }
    
}
