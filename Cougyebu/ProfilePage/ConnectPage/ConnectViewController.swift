//
//  ConnectViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

class ConnectViewController: UIViewController {
    private let connectView = ConnectView()
    private let viewModel: ConnectViewModel
    
    init (viewModel: ConnectViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = connectView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setAddTarget()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUI()
    }
    
    func setNavigationBar() {
        self.title = "커플 연결"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setUI() {
        guard let user = viewModel.observableUser?.value else { return }
        // 코드x, 연결x
        if user.code == nil {
            connectView.coupleCodeLabel.isHidden = true
            connectView.coupleCodeTextField.isHidden = true
            connectView.coupleCodeBottom.isHidden = true
            connectView.connectButton.setTitle("커플코드 생성", for: .normal)
            // 연결o
        } else if user.isConnect {
            connectView.coupleEmailTextField.text = user.coupleEmail
            connectView.coupleCodeLabel.isHidden = true
            connectView.coupleCodeTextField.isHidden = true
            connectView.coupleCodeBottom.isHidden = true
            connectView.connectButton.setTitle("연결 끊기", for: .normal)
            // 코드o, 연결x, 보낸사람
        } else if let code = user.code, let requestUser = user.requestUser, requestUser {
            connectView.coupleEmailTextField.text = user.coupleEmail
            connectView.coupleCodeLabel.text = "커플 코드"
            connectView.coupleCodeTextField.text = "\(code)"
            connectView.connectButton.isHidden = true
        }// 코드o, 연결x, 받은사람: 기본뷰
    }
    
    func setAddTarget() {
        connectView.connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
    }
    
    func checkEmail() {
        guard let email = connectView.coupleEmailTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "입력 확인", message: "이메일을 입력해주세요.", buttonTitle: "확인")
            return
        }
    }
    
    func checkEmailAndCode() {
        guard let email = connectView.coupleEmailTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "입력 확인", message: "이메일을 입력해주세요.", buttonTitle: "확인")
            return
        }
        guard let code = connectView.coupleCodeTextField.text?.trimmingCharacters(in: .whitespaces), !code.isEmpty else {
            AlertManager.showAlertOneButton(from: self, title: "입력 확인", message: "코드를 입력해주세요.", buttonTitle: "확인")
            return
        }
    }
    
    
    @objc func connectButtonTapped() {
        guard let user = viewModel.observableUser?.value else { return }
        // 코드x, 연결x
        if user.code == nil {
            checkEmail()
            guard let email = connectView.coupleEmailTextField.text else { return }
            
            viewModel.findId(email: email) { [weak self] bool in
                // 이메일 존재 x
                if !bool {
                    AlertManager.showAlertOneButton(from: self!, title: "이메일이 존재하지 않습니다", message: "", buttonTitle: "확인")
                } else {
                    // 이메일 존재 o
                    guard let randomNumber = self?.viewModel.makeRandomNumber() else { return }
                    guard let self = self else { return }
                    // 계정 연결
                    viewModel.connectUser(email: email, code: randomNumber, request: true)
                    AlertManager.showAlertOneButton(from: self, title: "연결코드입니다.", message: randomNumber, buttonTitle: "확인"){
                        self.connectView.coupleEmailTextField.isEnabled = false
                        self.connectView.coupleCodeLabel.isHidden = false
                        self.connectView.coupleCodeTextField.isHidden = false
                        self.connectView.coupleCodeBottom.isHidden = false
                        self.connectView.connectButton.isHidden = true
                        self.connectView.coupleEmailTextField.text = self.viewModel.observableUser?.value.coupleEmail
                        self.connectView.coupleCodeTextField.text = "\(randomNumber)"
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            // 코드o, 연결x
        } else if user.isConnect == false && user.requestUser == false {
            checkEmailAndCode()
            guard let email = connectView.coupleEmailTextField.text else { return }
            guard let code = connectView.coupleCodeTextField.text else { return }
            
            if email == user.coupleEmail && code == user.code {
                viewModel.updateUser(email: user.email, updatedFields: ["isConnect" : true]) { bool in }
                viewModel.updateUser(email: email, updatedFields: ["isConnect" : true]) { bool in }
                AlertManager.showAlertOneButton(from: self, title: "연결 성공", message: "연결되었습니다.", buttonTitle: "확인"){
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                AlertManager.showAlertOneButton(from: self, title: "코드 불일치", message: "연결 코드가 일치하지 않습니다.", buttonTitle: "확인")
            }
        }
        // 연결o
        else if user.isConnect {
            checkEmail()
            AlertManager.showAlertTwoButton(from: self, title: "연결 끊기", message: "정말 연결을 끊겠습니까?", button1Title: "확인", button2Title: "취소"){
                self.viewModel.disconnectUser(email: user.coupleEmail!)
                AlertManager.showAlertOneButton(from: self, title: "", message: "연결이 끊겼습니다.", buttonTitle: "확인") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    
    
    
    
}
