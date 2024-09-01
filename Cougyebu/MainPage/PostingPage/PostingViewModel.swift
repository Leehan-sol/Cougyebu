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
    
    var post: Posts?
    var postUpdated: PublishSubject<Void>
    var userEmail: String
    var coupleEmail: String
    var userIncomeCategory: [String]
    var userExpenditureCategory:  [String]
    var group = ["지출", "수입"]
    
    init(post: Posts?, postUpdated: PublishSubject<Void>, userEmail: String, coupleEmail: String, userIncomeCategory: [String], userExpenditureCategory: [String]) {
        self.post = post
        self.postUpdated = postUpdated
        self.userEmail = userEmail
        self.coupleEmail = coupleEmail
        self.userIncomeCategory = userIncomeCategory
        self.userExpenditureCategory = userExpenditureCategory
    }
    
    
    func addPost(date: String, posts: Posts) {
        postManager.addPost(email: userEmail, date: date, post: posts)
        
//        if range.contains(date) {
//            observablePost.value += [posts]
//            observablePost.value = observablePost.value.sorted(by: { $0.date < $1.date })
//        }
    }
    
    func updatePost(originalDate: String, uuid: String, post: Posts, completion: ((Bool?) -> Void)?) {
          postManager.updatePost(email: userEmail, originalDate: originalDate, uuid: uuid, post: post) { [weak self] bool in
              if bool == true {
                  guard let self = self else { return }
//                  guard let range = datesRange else { return }
//                  if let index = self.indexPath, range.contains(post.date) {
//                      self.observablePost.value[index] = post
//                      self.observablePost.value = (self.observablePost.value.sorted(by: { $0.date < $1.date }))
//                  } else if let index = self.indexPath {
//                      self.observablePost.value.remove(at: index)
//                  }
//                  completion?(true)
//              } else {
//                  self?.postManager.updatePost(email: self!.coupleEmail, originalDate: originalDate, uuid: uuid, post: post) { [weak self] bool in
//                      if bool == true {
//                          guard let self = self else { return }
//                          guard let range = datesRange else { return }
//                          if let index = self.indexPath, range.contains(post.date)  {
//                              self.observablePost.value[index] = post
//                              self.observablePost.value = (self.observablePost.value.sorted(by: { $0.date < $1.date }))
//                          } else if let index = self.indexPath {
//                              self.observablePost.value.remove(at: index)
//                          }
//                          completion?(true)
//                      } else {
//                          completion?(false)
//                      }
//                  }
              }
          }
      }

    
}
