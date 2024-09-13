//
//  PostingViewModel.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import Foundation
import RxSwift

class PostingViewModel {
    private let userManager = UserManager()
    private let postManager = PostManager()
    
    private let userEmail: String
    private let coupleEmail: String
    private let userIncomeCategory: [String]
    private let userExpenditureCategory: [String]
    private let postUpdated: PublishSubject<Void>
    
    private let alertAction = PublishSubject<(String, String)>()
    private let dismissAction = PublishSubject<Void>()
    
    private let post: BehaviorSubject<Post?>
    private let group = BehaviorSubject<[String]>(value: ["지출", "수입"])
    private let groupIndex = BehaviorSubject<Int?>(value: nil)
    private let categoryIndex = BehaviorSubject<Int?>(value: nil)
    private lazy var currentCategories = BehaviorSubject<[String]>(value: userExpenditureCategory)
    private let disposeBag = DisposeBag()
    
    
    struct Input {
        let postAddOrUpdateAction: PublishSubject<(String, Int, Int, String?, String?)>
        let selectGroupChangeAction: PublishSubject<String>
    }
    
    struct Output {
        let alertAction: PublishSubject<(String, String)>
        let dismissAction: PublishSubject<Void>
        let post: BehaviorSubject<Post?>
        let group: BehaviorSubject<[String]>
        let groupIndex: BehaviorSubject<Int?>
        let categoryIndex: BehaviorSubject<Int?>
        let currentCategories: BehaviorSubject<[String]>
    }
    
    func transform(input: Input) -> Output {
        input.postAddOrUpdateAction
            .bind(onNext: { date, groupIndex, categoryIndex, content, cost in
                self.addOrUpdatePost(date: date, groupIndex: groupIndex, categoryIndex: categoryIndex, content: content, cost: cost)
            }).disposed(by: disposeBag)
        
        input.selectGroupChangeAction
            .bind(onNext: { groupName in
                self.selectedGroupChange(name: groupName)
            }).disposed(by: disposeBag)
        
        
        return Output(alertAction: alertAction,
                      dismissAction: dismissAction,
                      post: post,
                      group: group,
                      groupIndex: groupIndex,
                      categoryIndex: categoryIndex,
                      currentCategories: currentCategories)
    }
    
    
    init(userEmail: String, coupleEmail: String, userIncomeCategory: [String], userExpenditureCategory: [String], post: BehaviorSubject<Post?>, postUpdated: PublishSubject<Void>) {
        self.userEmail = userEmail
        self.coupleEmail = coupleEmail
        self.userIncomeCategory = userIncomeCategory
        self.userExpenditureCategory = userExpenditureCategory
        self.post = post
        self.postUpdated = postUpdated
        setGroupAndCategory()
    }
    
    private func setGroupAndCategory() {
        guard let post = try? post.value() else { return }
        
        if let group = try? group.value(), let index = group.firstIndex(of: post.group) {
            groupIndex.onNext(index)
        }
        
        if post.group == "수입" {
            currentCategories.onNext(userIncomeCategory)
        } else {
            currentCategories.onNext(userExpenditureCategory)
        }
        
        if let category = try? currentCategories.value(), let index = category.firstIndex(of: post.category) {
            categoryIndex.onNext(index)
        }
    }
    
    private func selectedGroupChange(name: String) {
        if name == "수입" {
            currentCategories.onNext(userIncomeCategory)
        } else {
            currentCategories.onNext(userExpenditureCategory)
        }
    }
    
    private func addOrUpdatePost(date: String, groupIndex: Int, categoryIndex: Int, content: String?, cost: String?) {
        guard let group = try? group.value(), let category = try? currentCategories.value() else { return }
        let selectedGroup = group[groupIndex]
        let selectedCategory = category[categoryIndex]
        
        guard let content = content, !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertAction.onNext(("입력 오류", "내용을 입력하세요."))
            return
        }

        guard let cost = cost?.trimmingCharacters(in: .whitespaces), !cost.isEmpty else {
            alertAction.onNext(("입력 오류", "유효한 가격을 입력하세요."))
            return
        }
        let rawCost = cost.filter { $0.isNumber }

        guard let intCost = Int(rawCost) else {
            alertAction.onNext(("입력 오류", "유효한 가격을 입력하세요."))
            return
        }
        
        let uuid = UUID().uuidString
        let newPost = Post(date: date, group: selectedGroup, category: selectedCategory, content: content, cost: intCost.makeComma(num: intCost), uuid: uuid)
        
        if let post = try? post.value() {
            updatePost(originalDate: post.date, uuid: post.uuid, post: newPost)
        } else {
            addPost(date: date, posts: newPost)
        }
    }
    
    private func addPost(date: String, posts: Post) {
        postManager.addPost(email: userEmail, date: date, post: posts)
            .share(replay: 1)
            .subscribe(onNext: { [weak self] success in
                guard let self = self else { return }
                if success {
                    postUpdated.onNext(())
                    dismissAction.onNext(())
                }
            }, onError: { [weak self] error in
                guard let self = self else { return }
                alertAction.onNext(("게시글 작성 실패","게시글 작성에 실패했습니다. 다시 시도해주세요."))
            }).disposed(by: disposeBag)
    }
    
    private func updatePost(originalDate: String, uuid: String, post: Post) {
        if coupleEmail != "" {
            print(coupleEmail, userEmail)
            let updateCoupleEmailPost = postManager.updatePost(email: coupleEmail, originalDate: originalDate, uuid: uuid, post: post)
                .catch { error in
                    return Observable.just(false)
                }
            
            let updateUserEmailPost = postManager.updatePost(email: userEmail, originalDate: originalDate, uuid: uuid, post: post)
                .catch { error in
                    return Observable.just(false)
                }
            
            Observable.zip(updateCoupleEmailPost, updateUserEmailPost)
                .map { coupleSuccess, userSuccess in
                    return (coupleSuccess || userSuccess)
                }
                .subscribe(onNext: { [weak self] result in
                    guard let self = self else { return }
                    if !result {
                        alertAction.onNext(("게시글 수정 실패", "게시글 수정을 실패했습니다. 다시 시도해주세요."))
                    } else {
                        postUpdated.onNext(())
                        dismissAction.onNext(())
                    }
                }).disposed(by: disposeBag)
        } else {
            postManager.updatePost(email: userEmail, originalDate: originalDate, uuid: uuid, post: post)
                .subscribe(onError: { [weak self] error in
                    guard let self = self else { return }
                    alertAction.onNext(("게시글 수정 실패", "게시글 수정을 실패했습니다. 다시 시도해주세요."))
                }).disposed(by: disposeBag)
        }
        
    }
    
}
