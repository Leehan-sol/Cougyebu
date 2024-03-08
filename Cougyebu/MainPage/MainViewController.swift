//
//  MainViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

class MainViewController: UIViewController {
    private let mainView = MainView()
    private let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddtarget()
      //  loadPost()
    }
    
    func setAddtarget() {
        mainView.postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
    }
    
    // mainView.tableView.reloadData()
    func setBinding() {
        
    }
    
//    func loadPost() {
//        viewModel.loadPost(date: "2024.02.04")
//    }
    
    @objc func postButtonTapped() {
        viewModel.addPost(date: "2024.02.04", posts: [Posts(date: "2024.02.05", category: "카테고리", content: "내용", cost: 1600)])
    }
    
    
    
}


