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
    let group = BehaviorSubject<[String]>(value: ["지출", "수입"])
    
    var userEmail: String
    var coupleEmail: String
    var userIncomeCategory: [String]
    var userExpenditureCategory: [String]
    
    let post: BehaviorSubject<Posts?>
    let postUpdated: PublishSubject<Void>
    let dismissAction = PublishSubject<Void>()
    let alertAction = PublishSubject<(String, String)>()
    
    let groupIndex = BehaviorSubject<Int?>(value: nil)
    let categoryIndex = BehaviorSubject<Int?>(value: nil)
    
    lazy var currentCategories = BehaviorSubject<[String]>(value: userExpenditureCategory)
    private let disposeBag = DisposeBag()
    
    init(userEmail: String, coupleEmail: String, userIncomeCategory: [String], userExpenditureCategory: [String], post: BehaviorSubject<Posts?>, postUpdated: PublishSubject<Void>) {
        self.userEmail = userEmail
        self.coupleEmail = coupleEmail
        self.userIncomeCategory = userIncomeCategory
        self.userExpenditureCategory = userExpenditureCategory
        self.post = post
        self.postUpdated = postUpdated
        setGroupAndCategory()
    }
    
    func setGroupAndCategory() {
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
    
    func selectedGroupChange(name: String) {
        if name == "수입" {
            currentCategories.onNext(userIncomeCategory)
        } else {
            currentCategories.onNext(userExpenditureCategory)
        }
    }
    
    func addOrUpdatePost(date: String, groupIndex: Int, categoryIndex: Int, content: String?, cost: String?) {
        guard let group = try? group.value(), let category = try? currentCategories.value() else { return }
        let selectedGroup = group[groupIndex]
        let selectedCategory = category[categoryIndex]
        
        guard let content = content, !content.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertAction.onNext(("입력 오류", "내용을 입력하세요."))
            return
        }
        
        guard let cost = cost?.trimmingCharacters(in: .whitespaces), !cost.isEmpty, let intCost = Int(cost) else {
            alertAction.onNext(("입력 오류", "유효한 가격을 입력하세요."))
            return
        }
        
        let uuid = UUID().uuidString
        let newPost = Posts(date: date, group: selectedGroup, category: selectedCategory, content: content, cost: cost, uuid: uuid)
        
        if let post = try? post.value() {
            updatePost(originalDate: post.date, uuid: post.uuid, post: newPost)
        } else {
            addPost(date: date, posts: newPost)
        }
    }
    
    func addPost(date: String, posts: Posts) {
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
    
    func updatePost(originalDate: String, uuid: String, post: Posts) {
        if coupleEmail != "" {
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
