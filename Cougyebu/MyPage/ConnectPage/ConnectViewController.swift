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
        setUI()
        addTarget()
    }
    
    func setNavigationBar() {
        self.title = "커플 연결"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
    }
    
    func setUI() {
        guard let user = viewModel.observableUser?.value else { return }
        // 코드 x, 연결 x
        if user.code == nil {
            connectView.coupleCodeLabel.isHidden = true
            connectView.coupleCodeTextField.isHidden = true
            connectView.coupleCodeBottom.isHidden = true
            connectView.connectButton.setTitle("커플코드 생성", for: .normal)
            // 연결 o
        } else if user.isConnect {
            connectView.coupleEmailTextField.text = user.coupleEmail
            connectView.coupleCodeLabel.isHidden = true
            connectView.coupleCodeTextField.isHidden = true
            connectView.coupleCodeBottom.isHidden = true
            connectView.connectButton.setTitle("연결 끊기", for: .normal)
            // 코드 o, 연결 x
        } else if let code = user.code {
            connectView.coupleEmailTextField.text = user.coupleEmail
            connectView.coupleCodeLabel.text = "커플 코드"
            connectView.coupleCodeTextField.text = "\(code)"
            connectView.connectButton.isHidden = true
        }
    }
    
    func addTarget() {
        connectView.connectButton.addTarget(self, action: #selector(connectButtonTapped), for: .touchUpInside)
    }
    
    @objc func connectButtonTapped() {
        guard let user = viewModel.observableUser?.value else { return }
        // 연결 x
        if user.code == nil, let email = connectView.coupleEmailTextField.text?.trimmingCharacters(in: .whitespaces), !email.isEmpty {
            viewModel.findId(email: email) { [weak self] bool in
                // 이메일 존재 x
                if !bool {
                    AlertManager.showAlertOneButton(from: self!, title: "이메일이 존재하지 않습니다", message: "", buttonTitle: "확인")
                } else {
                    // 이메일 존재 o
                    guard let randomNumber = self?.viewModel.makeRandomNumber() else { return }
                    guard let self = self else { return }
                    viewModel.connectUser(email: email, code: randomNumber)
                    AlertManager.showAlertOneButton(from: self, title: "연결코드입니다.", message: randomNumber, buttonTitle: "확인"){
                        self.connectView.coupleEmailTextField.isEnabled = false
                        self.connectView.coupleCodeLabel.isHidden = false
                        self.connectView.coupleCodeTextField.isHidden = false
                        self.connectView.coupleCodeBottom.isHidden = false
                        self.connectView.connectButton.isHidden = true
                        // 기웅@naver.com
                        self.connectView.coupleEmailTextField.text = self.viewModel.observableUser?.value.coupleEmail
                        self.connectView.coupleCodeTextField.text = "\(randomNumber)"
                    }
                }
            }
        }
    }
    

    
    
    
    
}
