//
//  MainViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let fsManager = FirestoreManager()
    
    // 1. 뷰모델 생성
    // ✨ 의존성주입하기
    private let mainVM = MainViewModel()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddtarget()
    }
    
    func setAddtarget() {
        mainView.postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    
    // 2. bind함수를 통해 listner 클로저 정의
    func setBinding() {
        mainView.postButton.setTitle("유저 바인딩 성공", for: .normal)
    }
    
    
    // ✨ 게시글 등록하면서 user에 postRef도 생성해야함
    // currentEmail, coupleEmail로 postRef로 경로에 있는 게시글 찾아와서 보여주기
    @objc func postButtonTapped() {
        fsManager.addPost(email: "user.email", post: Post(postingDate: "2024.02.04", category: "카테고리", content: "내용", cost: 500))
    }
    
    
    
}


