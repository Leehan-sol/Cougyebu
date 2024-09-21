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
    private let rxUser = BehaviorSubject<User?>(value: nil)
    private let lastDate = BehaviorSubject<Date?>(value: nil)

    private let isLoading = BehaviorSubject(value: false)
    private let postUpdated = PublishSubject<Void>()
    private let alertAction = PublishSubject<(String, String)>()
    private let movePostPageAction = PublishSubject<PostingViewModel>()
    
    private let rxPosts = BehaviorSubject<[Post]>(value: [])
    private let postsPrice = BehaviorSubject<(Int, Int, Int)>(value: (0, 0, 0))

    private let firstDate = BehaviorSubject<Date?>(value: nil)
    private let existingFirstDate = PublishSubject<Date?>()
    private let selectDate = BehaviorSubject<Date?>(value: nil)
    private let deselectDate = BehaviorSubject<Date?>(value: nil)
    lazy var datesRange = BehaviorSubject<[String]>(value: currentDate.getAllDatesInMonth())
    private let disposeBag = DisposeBag()
    
    struct Input {
        let loadCategoryAction: PublishSubject<Void>
        let makePostingVMAction: PublishSubject<Int?>
        let deletePostAction: PublishSubject<Int>
        let calendarSelectAction: PublishSubject<Date>
        let calendarDeselectAction: PublishSubject<Date>   
    }
    
    struct Output {
        let isLoading: BehaviorSubject<Bool>
        let alertAction: PublishSubject<(String, String)>
        let movePostPageAction: PublishSubject<PostingViewModel>
        let rxPosts: BehaviorSubject<[Post]>
        let postsPrice: BehaviorSubject<(Int, Int, Int)>
        let firstDate: BehaviorSubject<Date?>
        let existingFirstDate: PublishSubject<Date?>
        let selectDate: BehaviorSubject<Date?>
        let deselectDate: BehaviorSubject<Date?>
        let datesRange: BehaviorSubject<[String]>
    }
    
    func transform(input: Input) -> Output {
        input.loadCategoryAction
            .bind(onNext: { _ in
                self.loadCategory()
            }).disposed(by: disposeBag)
        
        input.makePostingVMAction
            .bind(onNext: { index in
                self.makePostingVM(index: index)
            }).disposed(by: disposeBag)
        
        input.deletePostAction
            .bind(onNext: { index in
                self.deletePost(index: index)
            }).disposed(by: disposeBag)
        
        input.calendarSelectAction
            .bind(onNext: { date in
                self.calendarDidSelect(date: date)
            }).disposed(by: disposeBag)
        
        input.calendarDeselectAction
            .bind(onNext: { date in
                self.calendarDidDeselect(date: date)
            }).disposed(by: disposeBag)
        
        return Output(isLoading: isLoading,
                      alertAction: alertAction,
                      movePostPageAction: movePostPageAction,
                      rxPosts: rxPosts,
                      postsPrice: postsPrice,
                      firstDate: firstDate,
                      existingFirstDate: existingFirstDate,
                      selectDate: selectDate,
                      deselectDate: deselectDate,
                      datesRange: datesRange)
    }
    
    init(userEmail: String) {
        self.userEmail = userEmail
        dateFormatter.dateFormat = "yyyy.MM.dd"
        setUserAndPosts()
    }
    
    private func setUserAndPosts() {
        userManager.findUser(email: userEmail)
            .subscribe(onNext: { [weak self] user in
                guard let self = self else { return }
                isLoading.onNext(true)
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
    
    private func loadCategory() {
        userManager.findCategory(email: userEmail)
            .subscribe(onNext: { [weak self] (income, expenditure) in
                guard let self = self else { return }
                userIncomeCategory = income
                userExpenditureCategory = expenditure
            }).disposed(by: disposeBag)
    }
    
    private func loadPost(dates: [String]) {
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
    
    private func calculatePostPrice() {
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
    
    private func deletePost(index: Int) {
        guard let post = try? rxPosts.value()[index] else { return }
        guard let user = try? rxUser.value() else { return }
        
        if let coupleEmail = user.coupleEmail, user.isConnect == true {
            let deleteCoupleEmail = postManager.deletePost(email: coupleEmail, date: post.date, uuid: post.uuid)
                .catch { error in
                    return Observable.just(false)
                }
            
            let deleteUserEmail = postManager.deletePost(email: userEmail, date: post.date, uuid: post.uuid)
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
                        alertAction.onNext(("게시글 삭제 실패", "게시글 삭제에 실패했습니다. 다시 시도해주세요."))
                    } else {
                        if var currentPosts = try? rxPosts.value() {
                            currentPosts.remove(at: index)
                            rxPosts.onNext(currentPosts)
                        }
                    }
                }).disposed(by: disposeBag)
        } else {
            postManager.deletePost(email: userEmail, date: post.date, uuid: post.uuid)
                .subscribe(onError: { [weak self] error in
                    guard let self = self else { return }
                    alertAction.onNext(("게시글 삭제 실패","게시글 삭제에 실패했습니다. 다시 시도해주세요."))
                }).disposed(by: disposeBag)
        }
    }
    
    private func makePostingVM(index: Int?) {
        guard let user = try? rxUser.value() else { return }
        
        let postSubject = {
            if let index = index {
                let selectedPost = try? rxPosts.value()[index]
                return BehaviorSubject<Post?>(value: selectedPost)
            } else {
                return BehaviorSubject<Post?>(value: nil)
            }
        }()
        
        let postingVM = PostingViewModel(
            userEmail: userEmail,
            coupleEmail: user.coupleEmail ?? "",
            userIncomeCategory: userIncomeCategory,
            userExpenditureCategory: userExpenditureCategory,
            post: postSubject,
            postUpdated: postUpdated
        )
        movePostPageAction.onNext(postingVM)
    }

    private func calendarDidSelect(date: Date) {
        let first = try? firstDate.value()
        let last = try? lastDate.value()
        let dates = try? datesRange.value()
        
        if first == nil {
            firstDate.onNext(date)
            datesRange.onNext([])
            return
        }
        
        if first != nil && last == nil {
            if date < first! {
                existingFirstDate.onNext(first)
                firstDate.onNext(date)
                datesRange.onNext([])
                return
            } else {
                var range = [Date]()
                var currentDate = first!
                while currentDate <= date {
                    range.append(currentDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                
                var rangeString = [String]()
                for day in range {
                    let dateString = dateFormatter.string(from: day)
                    rangeString.append(dateString)
                    selectDate.onNext(day)
                }
                firstDate.onNext(range.first)
                lastDate.onNext(range.last)
                datesRange.onNext(rangeString)
            }
        }
        
        if first != nil && last != nil {
            for date in dates! {
                let dateTypeDate = date.fromString(date)
                deselectDate.onNext(dateTypeDate)
            }
            firstDate.onNext(date)
            lastDate.onNext(nil)
            datesRange.onNext([])
        }
        
    }
    
    private func calendarDidDeselect(date: Date) {
        let dates = try? datesRange.value()
        
        for date in dates! {
            let dateTypeDate = date.fromString(date)
            deselectDate.onNext(dateTypeDate)
        }
        firstDate.onNext(nil)
        lastDate.onNext(nil)
        datesRange.onNext([])
    }
}


