//
//  PostingViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class PostingViewController: UIViewController {
    private let postingView = PostingView()
    private let viewModel: PostingViewModel
    
    init(viewModel: PostingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        view = postingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAddTarget()
    }
    
    func setAddTarget() {
        postingView.addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    
    @objc func addButtonTapped() {
            viewModel.addPost(date: "2024.02.04", posts: [Posts(date: "2024.02.05", category: "카테고리", content: "내용", cost: 1600)])
    }
}
