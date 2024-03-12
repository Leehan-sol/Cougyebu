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
    var observablePost: Observable<[Posts]> = Observable<[Posts]>([])
    
    var userEmail: String
    var userIncomeCategory: [String] = []
    var userExpenditureCategory: [String] = []
    var coupleEmail: String?
    var isConnect: Bool?
    private let currentDate = Date()
    lazy var allDatesInMonth: [String] = currentDate.getAllDatesInMonthAsString()
    
    init(userEmail: String) {
        self.userEmail = userEmail
        self.observableUser = Observable<User>(User(email: "", nickname: "", isConnect: false))
    }
    
    // user 세팅
    func setUser() {
        userManager.findUser(email: userEmail) { [self] user in
            guard let user = user else { return }
            self.observableUser?.value = user
            self.coupleEmail = user.coupleEmail
            self.isConnect = user.isConnect
            self.loadPost(dates: allDatesInMonth)
        }
    }
    
    func loadPost(dates: [String]) {
        var loadedPosts: [Posts] = []
        
        for date in dates {
            // 커플 이메일
            if let coupleEmail = coupleEmail, isConnect == true {
                postManager.loadPosts(email: coupleEmail, date: date) { [weak self] posts in
                    if let post = posts {
                        loadedPosts.append(contentsOf: post)
                    }
                    self?.observablePost.value = loadedPosts.sorted(by: { $0.date < $1.date }) // 데이터 갱신
                }
            }
            // 사용자 이메일
            postManager.loadPosts(email: userEmail, date: date) { [weak self] posts in
                if let post = posts {
                    loadedPosts.append(contentsOf: post)
                }
                self?.observablePost.value = loadedPosts.sorted(by: { $0.date < $1.date }) // 데이터 갱신
            }
        }
    }
    
    
    func deletePost(date: String, uuid: String, completion: ((Bool?) -> Void)?) {
        postManager.deletePost(email: userEmail, date: date, uuid: uuid) { [weak self] bool in
            if bool == true {
                completion?(true)
            } else {
                guard let self = self else { return }
                guard let coupleEmail = coupleEmail else { return }
                self.postManager.deletePost(email: coupleEmail, date: date, uuid: uuid) { bool in
                    if bool == true {
                        completion?(true)
                    } else {
                        completion?(false)
                    }
                }
            }
        }
    }
    
    func calculatePrice() -> (income: Int, expenditure: Int, netIncome: Int) {
        var totalIncome = 0
        var totalExpenditure = 0
        
        for post in observablePost.value {
            let costStringWithoutComma = post.cost.replacingOccurrences(of: ",", with: "")
            if let cost = Int(costStringWithoutComma) {
                if post.group == "수입" {
                    totalIncome += cost
                } else if post.group == "지출" {
                    totalExpenditure += cost
                }
            }
        }
        
        let netIncome = totalIncome - totalExpenditure
        
        return (totalIncome, totalExpenditure, netIncome)
    }
    
    
    
    func loadCategory() {
        userManager.findCategory(email: userEmail) { incomeCategory, expenditureCategory in
            if let incomeCategory = incomeCategory {
                self.userIncomeCategory = incomeCategory
            }
            if let expenditureCategory = expenditureCategory {
                self.userExpenditureCategory = expenditureCategory
            }
        }
    }
    
    
    
}
