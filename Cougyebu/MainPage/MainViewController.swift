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
        setViewModelUser()
        loadPost()
        setBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCategory()
        loadTotalCost()
    }
    
    func setAddtarget() {
        mainView.datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        mainView.floatingButton.addTarget(self, action: #selector(floatingButtonTapped), for: .touchUpInside)
    }
    
    func setTableView() {
        mainView.tableView.delegate = self
        mainView.tableView.dataSource = self
        mainView.tableView.register(MainTableViewCell.self, forCellReuseIdentifier: "MainCell")
    }
    
    func setViewModelUser() {
        viewModel.setUser()
    }
    
    func setPlaceholderLabel() {
        if viewModel.observablePost.value.isEmpty {
            mainView.placeholderLabel.isHidden = false
        } else {
            mainView.placeholderLabel.isHidden = true
        }
    }
    
    func loadPost(date: String = Date().toString(format: "yyyy.MM.dd")) {
        viewModel.loadPost(email: viewModel.userEmail, date: date)
    }
    
    func loadCategory() {
        viewModel.loadCategory()
    }
    
    func loadTotalCost() {
        let cost = self.viewModel.addCost()
        mainView.totalLabel.text = "\(makeComma(num: cost))원"
    }
    
    func makeComma(num: Int) -> String {
        let numberFormatter: NumberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let costResult: String = numberFormatter.string(for: num) ?? ""
        return costResult
    }
    
    func setBinding() {
        viewModel.observablePost.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.mainView.tableView.reloadData()
                self?.loadTotalCost()
                self?.setPlaceholderLabel()
            }
        }
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateString = selectedDate.toString(format: "yyyy.MM.dd")
        viewModel.loadPost(email: viewModel.userEmail, date: dateString)
    }
    
    @objc func floatingButtonTapped() {
        let postingVM = PostingViewModel(observablePost: viewModel.observablePost, userEmail: viewModel.userEmail, userCategory: viewModel.userCategory)
        let postingVC = PostingViewController(viewModel: postingVM)
        present(postingVC, animated: true)
    }
    
    
}

// MARK: - UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// MARK: - UITableViewDataSource
extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.observablePost.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainTableViewCell
        let post = viewModel.observablePost.value[indexPath.row]
        
        cell.categoryLabel.text = post.category
        cell.contentLabel.text = post.content
        cell.priceLabel.text = "\(post.cost)원"
        
        return cell
    }
    
}
