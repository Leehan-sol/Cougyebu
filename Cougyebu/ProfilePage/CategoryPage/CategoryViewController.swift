//
//  CategoryViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class CategoryViewController: UIViewController {
    private let categoryView = CategoryView()
    private let userManager = UserManager()
    private let user: Observable<User>?
    
    init(user: Observable<User>?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = categoryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
    }
    
    func setNavigationBar() {
        self.title = "카테고리 설정"
        navigationController?.navigationBar.tintColor = .black
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setTableView() {
        categoryView.tableView.delegate = self
        categoryView.tableView.dataSource = self
    }
    
    @objc func addButtonTapped() {
        AlertManager.showAlertWithOneTF(from: self, title: "카테고리 추가", message: "추가할 카테고리를 입력해주세요.", placeholder: "카테고리명", button1Title: "확인", button2Title: "취소") { text in
            if let text = text {
                self.user?.value.category?.append(text)
                self.categoryView.tableView.reloadData()
                if let email = self.user?.value.email {
                    self.userManager.addCategory(email: email, category: text)
                }
            }
        }
    }

    
}

// MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let email = user?.value.email else { return }
            guard let categoryToDelete = user?.value.category?[indexPath.row] else { return }
            userManager.deleteCategory(email: email, category: categoryToDelete)
            user?.value.category?.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
}


// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return user?.value.category?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        if let category = user?.value.category?[indexPath.row] {
            cell.textLabel?.text = category
        }
        return cell
    }
    
    
    
    
}
