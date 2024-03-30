//
//  LoginViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Combine
import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    private let loginView = LoginView()
    // 👉🏻 의존성주입으로 변경하기
    private let viewModel = LoginViewModel()
    private var cancelBags = Set<AnyCancellable>()
    
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigation()
        setTextField()
        setupAddTarget()
        bindViewToViewModel()
        bindViewModelToView()
    }
    
    // MARK: - Methods
    func setNavigation(){
        navigationItem.leftBarButtonItem = nil
    }
    
    func setTextField(){
        loginView.idTextField.delegate = self
        loginView.pwTextField.delegate = self
    }
    
    func setupAddTarget() {
        loginView.showPwButton.addTarget(self, action: #selector(showPwButtonTapped), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.findIdButton.addTarget(self, action: #selector(findIdButtonTapped), for: .touchUpInside)
        loginView.findPwButton.addTarget(self, action: #selector(findPwButtonTapped), for: .touchUpInside)
        loginView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }
    
    // 👉🏻 1. 뷰모델의 id, password 프로퍼티에 assign
    private func bindViewToViewModel() {
        loginView.idTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.id, on: viewModel)
            .store(in: &cancelBags)
        
        loginView.pwTextField.textPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.password, on: viewModel)
            .store(in: &cancelBags)
    }
    
    // 👉🏻 2. 뷰모델의 퍼블리셔 뷰에 바인딩
    private func bindViewModelToView() {
        viewModel.checkResult
            .sink { value in
                if let id = value {
                    self.loginSuccess(email: id)
                } else {
                    AlertManager.showAlertOneButton(from: self, title: "로그인 실패", message: "아이디 또는 비밀번호가 틀렸습니다.", buttonTitle: "확인")
                }
            }
            .store(in: &cancelBags)
    }
    
    
    // MARK: - @objc
    @objc func showPwButtonTapped(){
        loginView.showPwButton.isSelected.toggle()
        
        if loginView.showPwButton.isSelected {
            loginView.showPwButton.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            loginView.pwTextField.isSecureTextEntry = true
        } else {
            loginView.showPwButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
            loginView.pwTextField.isSecureTextEntry = false
        }
        
    }
    
    @objc func loginButtonTapped() {
        viewModel.loginButtonTapped()
    }
    
    
    func loginSuccess(email: String) {
        if let currentUserEmail = Auth.auth().currentUser?.email {
            let mainVM = MainViewModel(userEmail: currentUserEmail)
            let mainVC = MainViewController(viewModel: mainVM)
            let mainNavi = UINavigationController(rootViewController: mainVC)
            
            let chartVM = ChartViewModel(userEmail: currentUserEmail)
            let chartVC = ChartViewController(viewModel: chartVM)
            
            let myPageVM = MyPageViewModel(userEmail: currentUserEmail)
            let myPageVC = MyPageViewController(viewModel: myPageVM)
            let myPageNavi = UINavigationController(rootViewController: myPageVC)
            
            let tabBarVC = UITabBarController()
            tabBarVC.setViewControllers([mainNavi, chartVC, myPageNavi], animated: false)
            tabBarVC.modalPresentationStyle = .fullScreen
            tabBarVC.tabBar.backgroundColor = .white
            tabBarVC.tabBar.tintColor = .black
            
            if let items = tabBarVC.tabBar.items {
                items[0].title = "Main"
                items[0].image = UIImage(systemName: "folder")
                items[1].title = "Chart"
                items[1].image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                items[2].title = "My Page"
                items[2].image = UIImage(systemName: "person")
            }
            UIApplication.shared.windows.first?.rootViewController = tabBarVC
            UIApplication.shared.windows.first?.makeKeyAndVisible()
        }
    }
    
    
    @objc func findIdButtonTapped() {
        //        let alertController = UIAlertController(title: "아이디 찾기", message: "등록한 닉네임을 입력해주세요.", preferredStyle: .alert)
        //
        //        alertController.addTextField { textField in
        //            textField.placeholder = "닉네임"
        //        }
        //
        //        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        //        let findAction = UIAlertAction(title: "찾기", style: .default) { [weak self] _ in
        //            if let nickname = alertController.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) {
        //                if !nickname.isEmpty {
        //                    self?.findIdByNickname(nickname)
        //                }
        //            }
        //        }
        //
        //        alertController.addAction(cancelAction)
        //        alertController.addAction(findAction)
        //        present(alertController, animated: true, completion: nil)
    }
    
    // 👉🏻 뷰모델로 로직 옮기기
    func findIdByNickname(_ nickname: String) {
        //        userManager.findNickname(nickname: nickname) { user in
        //            let alertTitle: String
        //            let alertMessage: String
        //
        //            if let user = user {
        //                alertTitle = "아이디 찾기 성공"
        //                alertMessage = self.maskEmail(user.email)
        //            } else {
        //                alertTitle = "아이디 찾기 실패"
        //                alertMessage = "해당 닉네임을 가진 사용자를 찾을 수 없습니다."
        //            }
        //            AlertManager.showAlertOneButton(from: self, title: alertTitle, message: alertMessage, buttonTitle: "확인")
        //        }
    }
    
    // ✨ 이메일 가리는 로직 수정
    func maskEmail(_ email: String) -> String {
        let emailArray = Array(email)
        var maskedEmail = ""
        for (index, char) in emailArray.enumerated() {
            if index > 1 && index < 6 && char != "@" {
                maskedEmail.append("*")
            } else {
                maskedEmail.append(char)
            }
        }
        return maskedEmail
    }
    
    
    @objc func findPwButtonTapped() {
        let passwordChangeVC = PasswordChangeViewController()
        self.navigationController?.pushViewController(passwordChangeVC, animated: true)
    }
    
    @objc func registerButtonTapped() {
        let registerVC = RegisterViewController()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.idTextField {
            loginView.pwTextField.becomeFirstResponder()
        } else if textField == loginView.pwTextField {
            loginButtonTapped()
        }
        return true
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == loginView.idTextField {
            loginView.idLabel.font = UIFont.systemFont(ofSize: 9)
            loginView.idLabelCenterY.constant = -18
        }
        if textField == loginView.pwTextField {
            loginView.pwLabel.font = UIFont.systemFont(ofSize: 9)
            loginView.pwLabelCenterY.constant = -18
        }
        UIView.animate(withDuration: 0.3) {
            self.loginView.layoutIfNeeded()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == loginView.idTextField {
            if loginView.idTextField.text == "" {
                loginView.idLabel.font = UIFont.systemFont(ofSize: 16)
                loginView.idLabelCenterY.constant = 0
            }
        }
        if textField == loginView.pwTextField {
            if loginView.pwTextField.text == ""{
                loginView.pwLabel.font = UIFont.systemFont(ofSize: 16)
                loginView.pwLabelCenterY.constant = 0
            }
        }
        UIView.animate(withDuration: 0.3) {
            self.loginView.layoutIfNeeded()
        }
    }
    
    
    
    
}
