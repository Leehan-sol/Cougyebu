//
//  WithdrawalViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FirebaseAuth

class WithdrawalViewController: UIViewController {
    private let withdrawalView = WithdrawalView()
    private let userManager = UserManager()
    private let postManager = PostManager()
    private let user: Observable<User>?
    
    init(user: Observable<User>?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coㅌder:) has not been implemented")
    }
    
    override func loadView() {
        view = withdrawalView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTextField()
        addTarget()
    }
    
    func setNavigationBar() {
        self.title = "회원탈퇴"
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setTextField() {
        withdrawalView.passwordTextField.delegate = self
    }
    
    func addTarget() {
        withdrawalView.passwordButton.addTarget(self, action: #selector(checkPasswordButtonTapped), for: .touchUpInside)
        withdrawalView.withdrawalButton.addTarget(self, action: #selector(withdrawalButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - @objc
    @objc func checkPasswordButtonTapped() {
        withdrawalView.passwordButton.isSelected.toggle()
        
        if withdrawalView.passwordButton.isSelected {
            withdrawalView.passwordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            withdrawalView.passwordTextField.isSecureTextEntry = true
        } else {
            withdrawalView.passwordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            withdrawalView.passwordTextField.isSecureTextEntry = false
        }
    }
    
    @objc func withdrawalButtonTapped() {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: withdrawalView.passwordTextField.text ?? "")
        
        user?.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("현재 비밀번호 확인 실패: \(error.localizedDescription)")
                AlertManager.showAlertOneButton(from: self, title: "비밀번호 확인 실패", message: "입력한 비밀번호가 올바르지 않습니다.", buttonTitle: "확인")
            } else {
                print("비밀번호 확인 성공")
                AlertManager.showAlertTwoButton(from: self, title: "회원탈퇴", message: "정말 탈퇴하시겠습니까?", button1Title: "확인", button2Title: "취소") {
                    if let user = Auth.auth().currentUser {
                        user.delete { error in
                            if let error = error {
                                print("Firebase Error: \(error)")
                            } else {
                                if let coupleEmail = self.user?.value.coupleEmail, let email = self.user?.value.email {
                                    self.userManager.deleteUser(user: user)
                                    self.postManager.deleteAllPost(email: email) { _ in }
                                    self.userManager.disconnectUser(inputEmail: coupleEmail) { _ in }
                                    
                                    // 로그인 화면으로 이동
                                    let loginVC = LoginViewController()
                                    let loginNavi = UINavigationController(rootViewController: loginVC)
                                    UIApplication.shared.windows.first?.rootViewController = loginNavi
                                    UIApplication.shared.windows.first?.makeKeyAndVisible()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    
    
}


// MARK: - UITextFieldDelegate
extension WithdrawalViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
}
