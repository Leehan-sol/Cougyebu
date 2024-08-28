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
    private let currentDate = Date()
    let dateFormatter = DateFormatter()
    
    let isLoading: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let rxUser = BehaviorSubject<User?>(value: nil) // private으로 바꿀거
    let rxPosts = BehaviorSubject<[Posts]>(value: [])
    let postsPrice = BehaviorSubject<(Int, Int, Int)>(value: (0, 0, 0))
    let userIncomeCategory = BehaviorSubject<[String]>(value: [])
    let userExpenditureCategory = BehaviorSubject<[String]>(value: [])
    let movePostPage = PublishSubject<PostingViewModel>()
    
    let existingFirstDate = PublishSubject<Date?>()
    let existingSelectedDates = PublishSubject<[String]>()
    let selectedFirstDate = BehaviorSubject<Date?>(value: nil)
    let selectedLastDate = BehaviorSubject<Date?>(value: nil)
    let reloadCalendar = PublishSubject<Void>()
    lazy var selectedDates = BehaviorSubject<[String]>(value: currentDate.getAllDatesInMonth())
    private let disposeBag = DisposeBag()
    
    
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
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                if let dates = try? selectedDates.value() {
                    loadPost(dates: dates)
                }
            }).disposed(by: disposeBag)
        
        selectedDates
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
            .subscribe(onNext: { [weak self] (incomeCategory, expenditureCategory) in
                guard let self = self else { return }
                userIncomeCategory.onNext(incomeCategory)
                userExpenditureCategory.onNext(expenditureCategory)
            }).disposed(by: disposeBag)
    }
    
    func loadPost(dates: [String]) {
        guard let user = try? rxUser.value() else { return }
        
        isLoading.onNext(true)
        
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
    
    func makePostViewModel() {
        guard let user = try? rxUser.value() else { return }
        
        let postingVM = PostingViewModel(observablePost: rxPosts,
                                         userEmail: userEmail,
                                         coupleEmail: user.coupleEmail ?? "",
                                         userIncomeCategory: userIncomeCategory,
                                         userExpenditureCategory: userExpenditureCategory)
        movePostPage.onNext(postingVM)
    }
    
    func handleDateSelection(selectedDate: Date) {
        let firstDate = try? selectedFirstDate.value()
        let lastDate = try? selectedLastDate.value()
        let dates = try? selectedDates.value()
        
        print(#function, firstDate, lastDate, dates)
        
        if let firstDate = firstDate, let lastDate = lastDate {
            // 1. firstDate와 lastDate가 설정된 경우
            existingSelectedDates.onNext(dates ?? [])
            selectedLastDate.onNext(nil)
            selectedDates.onNext([])
            selectedFirstDate.onNext(selectedDate)
        } else if let firstDate = firstDate {
            if selectedDate < firstDate {
                // 2. firstDate 이전 날짜를 선택한 경우
                existingFirstDate.onNext(firstDate)
                selectedFirstDate.onNext(selectedDate)
            } else {
                // 3. firstDate 이후 날짜를 선택한 경우
                selectedLastDate.onNext(selectedDate)
                var range: [String] = []
                var currentDate = firstDate
                while currentDate <= selectedDate {
                    let stringDate = dateFormatter.string(from: currentDate)
                    range.append(stringDate)
                    currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
                }
                selectedDates.onNext(range)
            }
        } else {
            // 4. 처음 날짜를 선택한 경우
            selectedFirstDate.onNext(selectedDate)
        }
    }
    
    
    
    
    func handleDateDeselection(deselectedDate: Date) {
        let firstDate = try? selectedFirstDate.value()
        let lastDate = try? selectedLastDate.value()
        let dates = try? selectedDates.value()
        
        print(#function, firstDate, lastDate, dates)
        
        if let currentFirstDate = firstDate, let currentLastDate = lastDate, let currentDates = dates {
            existingSelectedDates.onNext(currentDates)
            selectedFirstDate.onNext(nil)
            selectedLastDate.onNext(nil)
            selectedDates.onNext([])
            reloadCalendar.onNext(())
        } else if let currentDates = dates {
            existingSelectedDates.onNext(currentDates)
            selectedDates.onNext([])
            reloadCalendar.onNext(())
        }
    }


}
