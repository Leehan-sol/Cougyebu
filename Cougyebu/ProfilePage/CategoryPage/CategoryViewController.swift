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
    private var category: [String] = []
    private var incomeOutcome: Bool? // 지출: false, 수입: true
    
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
        setAddTarget()
        setTableView()
    }
    
    func setNavigationBar() {
        self.title = "카테고리 설정"
        navigationController?.navigationBar.tintColor = .black
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setAddTarget() {
        categoryView.incomeButton.addTarget(self, action: #selector(incomeButtonTapped), for: .touchUpInside)
        categoryView.expenditureButton.addTarget(self, action: #selector(expenditureButtonTapped), for: .touchUpInside)
    }
    
    func setTableView() {
        category = user?.value.expenditureCategory ?? []
        incomeOutcome = false
        categoryView.tableView.delegate = self
        categoryView.tableView.dataSource = self
    }
    
    @objc func incomeButtonTapped() {
        category = user?.value.incomeCategory ?? []
        categoryView.incomeButton.backgroundColor = .black
        categoryView.incomeButton.setTitleColor(.white, for: .normal)
        categoryView.expenditureButton.backgroundColor = .systemGray6
        categoryView.expenditureButton.setTitleColor(.black, for: .normal)
        categoryView.tableView.reloadData()
        incomeOutcome = true
    }
    
    @objc func expenditureButtonTapped() {
        category = user?.value.expenditureCategory ?? []
        categoryView.expenditureButton.backgroundColor = .black
        categoryView.expenditureButton.setTitleColor(.white, for: .normal)
        categoryView.incomeButton.backgroundColor = .systemGray6
        categoryView.incomeButton.setTitleColor(.black, for: .normal)
        categoryView.tableView.reloadData()
        incomeOutcome = false
    }
    
    @objc func addButtonTapped() {
        AlertManager.showAlertWithOneTF(from: self, title: "카테고리 추가", message: "추가할 카테고리를 입력해주세요.", placeholder: "카테고리명", button1Title: "확인", button2Title: "취소") { text in
            guard let text = text else { return }
            if self.incomeOutcome == true {
                self.user?.value.incomeCategory?.append(text)
                self.category = self.user?.value.incomeCategory ?? []
                self.categoryView.tableView.reloadData()
                if let email = self.user?.value.email {
                    self.userManager.addCategory(email: email, category: text, categoryType: "income")
                }
            } else {
                self.user?.value.expenditureCategory?.append(text)
                self.category = self.user?.value.expenditureCategory ?? []
                self.categoryView.tableView.reloadData()
                if let email = self.user?.value.email {
                    self.userManager.addCategory(email: email, category: text, categoryType: "expenditure")
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
            var categoryToDelete: String = ""
            if incomeOutcome == true {
                categoryToDelete = user?.value.incomeCategory?[indexPath.row] ?? ""
                user?.value.incomeCategory?.remove(at: indexPath.row)
                self.category = self.user?.value.incomeCategory ?? []
                userManager.deleteCategory(email: email, category: categoryToDelete, categoryType: "income")
            } else {
                categoryToDelete = user?.value.expenditureCategory?[indexPath.row] ?? ""
                user?.value.expenditureCategory?.remove(at: indexPath.row)
                self.category = self.user?.value.expenditureCategory ?? []
                userManager.deleteCategory(email: email, category: categoryToDelete, categoryType: "expenditure")
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


    
    
}


// MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = category[indexPath.row]
        return cell
    }
    
    
    
    
}
