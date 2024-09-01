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
    private var userIncomeCategory = [String]()
    private var userExpenditureCategory = [String]()
    private let currentDate = Date()
    private let dateFormatter = DateFormatter()
    
    // private으로 바꿀거
    let isLoading = BehaviorSubject(value: false)
    let postUpdated = PublishSubject<Void>()
    let alertAction = PublishSubject<(String, String)>()
    let movePostPage = PublishSubject<PostingViewModel>()
    
    let rxUser = BehaviorSubject<User?>(value: nil)
    let rxPosts = BehaviorSubject<[Posts]>(value: [])
    let postsPrice = BehaviorSubject<(Int, Int, Int)>(value: (0, 0, 0))

    let existingFirstDate = PublishSubject<Date?>()
    let firstDate = BehaviorSubject<Date?>(value: nil)
    let lastDate = BehaviorSubject<Date?>(value: nil)
    let selecteDate = BehaviorSubject<Date?>(value: nil)
    let deselecteDate = BehaviorSubject<Date?>(value: nil)
    lazy var datesRange = BehaviorSubject<[String]>(value: currentDate.getAllDatesInMonth())
    private let disposeBag = DisposeBag()
    
    
    init(userEmail: String) {
        self.userEmail = userEmail
        dateFormatter.dateFormat = "yyyy.MM.dd"
        setUserAndPosts()
    }
    
    func setUserAndPosts() {
        userManager.findUser(email: userEmail)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                rxUser.onNext(user)
            }).disposed(by: disposeBag)
        
        rxUser
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let dates = try? datesRange.value() {
                    loadPost(dates: dates)
                }
            }).disposed(by: disposeBag)
        
        postUpdated
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let dates = try? datesRange.value() {
                    loadPost(dates: dates)
                }
            }).disposed(by: disposeBag)
        
        datesRange
            .subscribe(onNext: { [weak self] dates in
                guard let self = self else { return }
                loadPost(dates: dates)
            }).disposed(by: disposeBag)
        
        rxPosts
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                calculatePostPrice()
            }).disposed(by: disposeBag)
    }
    
    func loadCategory() {
        userManager.findCategory(email: userEmail)
            .subscribe(onNext: { [weak self] (income, expenditure) in
                guard let self = self else { return }
                userIncomeCategory = income
                userExpenditureCategory = expenditure
            }).disposed(by: disposeBag)
    }
    
    func loadPost(dates: [String]) {
        guard let user = try? rxUser.value() else { return }
        
        isLoading.onNext(true)
        
        if let coupleEmail = user.coupleEmail, user.isConnect == true  {
            let coupleEmailPosts = postManager.fetchLoadPosts(email: coupleEmail, dates: dates)
            let userEmailPosts = postManager.fetchLoadPosts(email: userEmail, dates: dates)
            
            Observable.zip(coupleEmailPosts, userEmailPosts)
                .map { couplePosts, myPosts in
                    return (couplePosts + myPosts).sorted { $0.date < $1.date }
                }
                .subscribe(onNext: { [weak self] sortedPosts in
                    guard let self = self else { return }
                    rxPosts.onNext(sortedPosts)
                    isLoading.onNext(false)
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
                    isLoading.onNext(false)
                }).disposed(by: disposeBag)
        }
    }
    
    func calculatePostPrice() {
        rxPosts
            .map { posts in
                let totalIncome = posts
                    .filter { $0.group == "수입" }
                    .map { post in
                        Int(post.cost.replacingOccurrences(of: ",", with: "")) ?? 0
                    }
                    .reduce(0, +)
                
                let totalExpenditure = posts
                    .filter { $0.group == "지출" }
                    .map { post in
                        Int(post.cost.replacingOccurrences(of: ",", with: "")) ?? 0
                    }
                    .reduce(0, +)
                
                let result = totalIncome - totalExpenditure
                
                return (totalIncome, totalExpenditure, result)
            }
            .bind(to: postsPrice)
            .disposed(by: disposeBag)
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
                    guard let self = self else { return }
                    if !result {
                        alertAction.onNext(("삭제 실패","게시글 삭제에 실패했습니다. 다시 시도해주세요."))
                    } else {
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
    
    func makePostViewModel(index: Int?) {
        guard let user = try? rxUser.value() else { return }
        
        let selectPost = {
            if let index = index {
                return try? rxPosts.value()[index]
            }
            return nil
        }()
        
        let postingVM = PostingViewModel(
            post: selectPost,
            postUpdated: postUpdated,
            userEmail: userEmail,
            coupleEmail: user.coupleEmail ?? "",
            userIncomeCategory: userIncomeCategory,
            userExpenditureCategory: userExpenditureCategory
        )
        movePostPage.onNext(postingVM)
    }

    func calendarDidSelect(selectDate: Date) {
        let first = try? firstDate.value()
        let last = try? lastDate.value()
        let dates = try? datesRange.value()
        
        if first == nil {
            firstDate.onNext(selectDate)
            datesRange.onNext([])
            return
        }
        
        if first != nil && last == nil {
            if selectDate < first! {
                existingFirstDate.onNext(first)
                firstDate.onNext(selectDate)
                datesRange.onNext([])
                return
            } else {
                var range = [Date]()
                var currentDate = first!
                while currentDate <= selectDate {
                    range.append(currentDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                
                var rangeString = [String]()
                for day in range {
                    let dateString = dateFormatter.string(from: day)
                    rangeString.append(dateString)
                    selecteDate.onNext(day)
                }
                firstDate.onNext(range.first)
                lastDate.onNext(range.last)
                datesRange.onNext(rangeString)
            }
        }
        
        if first != nil && last != nil {
            for date in dates! {
                let dateTypeDate = date.fromString(date)
                deselecteDate.onNext(dateTypeDate)
            }
            firstDate.onNext(selectDate)
            lastDate.onNext(nil)
            datesRange.onNext([])
        }
        
    }
    
    func calendarDidDeselect(deselectDate: Date) {
        let dates = try? datesRange.value()
        
        for date in dates! {
            let dateTypeDate = date.fromString(date)
            deselecteDate.onNext(dateTypeDate)
        }
        firstDate.onNext(nil)
        lastDate.onNext(nil)
        datesRange.onNext([])
    }
}


