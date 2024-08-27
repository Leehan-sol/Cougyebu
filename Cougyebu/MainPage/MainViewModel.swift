//
//  MainViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()
    
    private let userEmail: String
    var rxUser = BehaviorSubject<User?>(value: nil) // private으로 바꿀거
    var rxPosts = BehaviorSubject<[Posts]>(value: []) // private으로 바꿀거
    private let disposeBag = DisposeBag()
    
    var userIncomeCategory: [String] = []
    var userExpenditureCategory: [String] = []
    
    private let currentDate = Date()
    lazy var allDatesInMonth: [String] = currentDate.getAllDatesInMonth()
    
    init(userEmail: String) {
        self.userEmail = userEmail
        setUserAndPosts()
    }
    
    func setUserAndPosts() {
        userManager.findUser(email: userEmail)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                rxUser.onNext(user)
            }).disposed(by: disposeBag)
        
        rxUser
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.loadPost(dates: allDatesInMonth)
            }).disposed(by: disposeBag)
    }
    
    
    func loadPost(dates: [String]) {
        guard let user = try? rxUser.value() else { return }
        
        if let coupleEmail = user.coupleEmail, user.isConnect == true  {
            let coupleEmailPosts = postManager.fetchLoadPosts(email: coupleEmail, dates: dates)
            let userEmailPosts = postManager.fetchLoadPosts(email: userEmail, dates: dates)
            
            Observable.combineLatest(coupleEmailPosts, userEmailPosts)
                .map { couplePosts, myPosts in
                    return (couplePosts + myPosts).sorted { $0.date < $1.date }
                }
                .subscribe(onNext: { [weak self] sortedPosts in
                    guard let self = self else { return }
                    rxPosts.onNext(sortedPosts)
                }).disposed(by: disposeBag)
        } else {
            postManager.fetchLoadPosts(email: userEmail, dates: dates)
                .map { posts in
                    return posts.sorted { $0.date < $1.date }
                }
                .subscribe(onNext: { [weak self] sortedPosts in
                    guard let self = self else { return
                    }
                    rxPosts.onNext(sortedPosts)
                }).disposed(by: disposeBag)
        }
    }
    
    func deletePost(index: Int) {
        guard let post = try? rxPosts.value()[index] else { return }
        guard let user = try? rxUser.value() else { return }
        
        if let coupleEmail = user.coupleEmail, user.isConnect == true {
            let deleteCoupleEmail = postManager.deletePost(email: coupleEmail, post: post)
                .catch { error in
                    return Observable.just(false)
                }
            
            let deleteUserEmail = postManager.deletePost(email: userEmail, post: post)
                .catch { error in
                    return Observable.just(false)
                }
            
            Observable.zip(deleteCoupleEmail, deleteUserEmail)
                .map { coupleSuccess, userSuccess in
                    return (coupleSuccess || userSuccess)
                }
                .subscribe(onNext: { [weak self] result in
                    print(result)
                    if !result {
                        print("삭제 실패") // 얼랏 이벤트 발행으로 수정
                    } else {
                        print("삭제 성공")
                        guard let self = self else { return }
                        if var currentPosts = try? rxPosts.value() {
                            currentPosts.remove(at: index)
                            rxPosts.onNext(currentPosts)
                        }
                    }
                }).disposed(by: disposeBag)
        } else {
            postManager.deletePost(email: userEmail, post: post)
                .subscribe(onError: { error in
                    print(error)
                }).disposed(by: disposeBag)
        }
    }
    
    
    
    func calculatePrice() -> (income: Int, expenditure: Int, netIncome: Int) {
        var totalIncome = 0
        var totalExpenditure = 0
        
        //        for post in observablePost.value {
        //            let costStringWithoutComma = post.cost.replacingOccurrences(of: ",", with: "")
        //            if let cost = Int(costStringWithoutComma) {
        //                if post.group == "수입" {
        //                    totalIncome += cost
        //                } else if post.group == "지출" {
        //                    totalExpenditure += cost
        //                }
        //            }
        //        }
        
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
