//
//  PasswordEditViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FirebaseAuth

class PasswordEditViewController: UIViewController {
    private let passwordEditView = PasswordEditView()
    
    override func loadView() {
        view = passwordEditView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTextField()
        setupAddTarget()
    }
    
    
    // MARK: - Methods
    func setNavigationBar() {
        self.title = "비밀번호 변경"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setTextField() {
        passwordEditView.passwordTextField.delegate = self
        passwordEditView.newPasswordTextField.delegate = self
        passwordEditView.changePasswordTextField.delegate = self
    }
    
    
    func setupAddTarget() {
        passwordEditView.changePasswordButton.addTarget(self, action: #selector(changePasswordButtonTapped), for: .touchUpInside)
        passwordEditView.passwordButton.addTarget(self, action: #selector(editPasswordButtonTapped), for: .touchUpInside)
        passwordEditView.newPasswordButton.addTarget(self, action: #selector(newPasswordButtonTapped), for: .touchUpInside)
        passwordEditView.checkPasswordButton.addTarget(self, action: #selector(checkPasswordButtonTapped), for: .touchUpInside)
    }
    
    
    // MARK: - @objc
    @objc func changePasswordButtonTapped() {
        if let currentPassword = passwordEditView.passwordTextField.text?.trimmingCharacters(in: .whitespaces),
           let newPassword = passwordEditView.newPasswordTextField.text?.trimmingCharacters(in: .whitespaces),
           let checkPassword = passwordEditView.changePasswordTextField.text?.trimmingCharacters(in: .whitespaces) {
            
            if currentPassword.isEmpty || newPassword.isEmpty || checkPassword.isEmpty {
                AlertManager.showAlertOneButton(from: self, title: "입력 필요", message: "모든 필드를 채워주세요.", buttonTitle: "확인")
            } else {
                changePassword(currentPassword: currentPassword, newPassword: newPassword, checkPassword: checkPassword)
            }
        }
    }
    
    @objc func editPasswordButtonTapped() {
        passwordEditView.passwordButton.isSelected.toggle()
        
        if passwordEditView.passwordButton.isSelected {
            passwordEditView.passwordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordEditView.passwordTextField.isSecureTextEntry = true
        } else {
            passwordEditView.passwordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            passwordEditView.passwordTextField.isSecureTextEntry = false
        }
    }
    
    @objc func newPasswordButtonTapped() {
        passwordEditView.newPasswordButton.isSelected.toggle()
        
        if passwordEditView.newPasswordButton.isSelected {
            passwordEditView.newPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordEditView.newPasswordTextField.isSecureTextEntry = true
        } else {
            passwordEditView.newPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            passwordEditView.newPasswordTextField.isSecureTextEntry = false
        }
    }
    
    @objc func checkPasswordButtonTapped() {
        passwordEditView.checkPasswordButton.isSelected.toggle()
        
        if passwordEditView.checkPasswordButton.isSelected {
            passwordEditView.checkPasswordButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            passwordEditView.changePasswordTextField.isSecureTextEntry = true
        } else {
            passwordEditView.checkPasswordButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            passwordEditView.changePasswordTextField.isSecureTextEntry = false
        }
    }
    
    
    func changePassword(currentPassword: String, newPassword: String, checkPassword: String) {
        let user = Auth.auth().currentUser
        let credential = EmailAuthProvider.credential(withEmail: user?.email ?? "", password: currentPassword)
        
        user?.reauthenticate(with: credential) { _, error in
            if let error = error {
                print("현재 비밀번호 확인 실패: \(error.localizedDescription)")
                AlertManager.showAlertOneButton(from: self, title: "비밀번호 확인 실패", message: "입력한 비밀번호가 올바르지 않습니다.", buttonTitle: "확인")
            } else if newPassword != checkPassword {
                AlertManager.showAlertOneButton(from: self, title: "비밀번호 불일치", message: "변경할 비밀번호가 일치하지않습니다.", buttonTitle: "확인")
            } else if !newPassword.isValidPassword() {
                AlertManager.showAlertOneButton(from: self, title: "유효하지 않은 비밀번호", message: "비밀번호는 대소문자, 특수문자, 숫자 8자 이상이여야합니다.", buttonTitle: "확인")
            } else {
                let user = Auth.auth().currentUser
                user?.updatePassword(to: newPassword) { error in
                    if let error = error {
                        print("비밀번호 변경 실패: \(error.localizedDescription)")
                    } else {
                        AlertManager.showAlertOneButton(from: self, title: "변경 성공", message: "비밀번호가 변경되었습니다.", buttonTitle: "확인") {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}


// MARK: - UITextFieldDelegate
extension PasswordEditViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == passwordEditView.passwordTextField {
            passwordEditView.newPasswordTextField.becomeFirstResponder()
        } else if textField == passwordEditView.newPasswordTextField {
            passwordEditView.changePasswordTextField.becomeFirstResponder()
        }
        return true
    }
    
    
}
