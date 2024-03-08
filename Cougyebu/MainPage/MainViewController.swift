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
        setTableView()
        setBinding()
        loadPost(date: "2024.02.04")
    }
    
    func setAddtarget() {
        mainView.floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    func setTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    func setBinding() {
        viewModel.observablePost.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.mainView.tableView.reloadData()
            }
        }
    }
    
    func loadPost(date: String) {
        viewModel.loadPost(date: date)
    }

    
    @objc func floatingButtonTapped() {
        // ✨ posts의 data는 시간까지 저장해야됨
        
        viewModel.addPost(date: "2024.02.04", posts: [Posts(date: "2024.02.05", category: "카테고리", content: "내용", cost: 1600)])
    }
    
//   func floatingButtonTapped(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "NewAlarm", bundle: nil)
//        let vc = storyboard.instantiateViewController(withIdentifier: "NewAlarmViewController") as! NewAlarmViewController
//    //        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
    
    
    
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.observablePost.value.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.observablePost.value[indexPath.row].content
   
        return cell
    }
    
}
