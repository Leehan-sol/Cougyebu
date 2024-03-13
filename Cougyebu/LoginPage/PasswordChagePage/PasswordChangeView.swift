//
//  PasswordChangeView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/13.
//

import UIKit

class PasswordChangeView: UIView {
    
    private let registerIdLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let registerIdTextField: UITextField = {
        let textField = UITextField()
        textField.setPlaceholderFontSize(size: 14, text: "가입하신 이메일 주소를 입력하세요.")
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .emailAddress
        textField.clearsOnBeginEditing = false
        return textField
    }()

    private let registerIdBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()

    let authIdButton: UIButton = {
        let button = UIButton()
        button.setTitle("인증메일전송", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return button
    }()

    private let authCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "인증번호"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()

    let authCodeTextField: UITextField = {
        let textField = UITextField()
        textField.setPlaceholderFontSize(size: 14, text: "받으신 인증번호를 입력하세요.")
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.clearsOnBeginEditing = false
        return textField
    }()

    private let authCodeBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()

    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()

    let authCodeButton: UIButton = {
        let button = UIButton()
        button.setTitle("인증확인", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return button
    }()

    let changePasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("비밀번호 재설정 이메일 발송", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemGray6
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        return button
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUI() {
        self.backgroundColor = .systemBackground
        
        addSubview(registerIdLabel)
        addSubview(registerIdTextField)
        addSubview(registerIdBottom)
        addSubview(authIdButton)
        
        addSubview(authCodeLabel)
        addSubview(authCodeTextField)
        addSubview(authCodeBottom)
        addSubview(timerLabel)
        addSubview(authCodeButton)
        
        addSubview(changePasswordButton)
        
        
        registerIdLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.left.equalToSuperview().offset(24)
        }
        registerIdTextField.snp.makeConstraints {
            $0.top.equalTo(registerIdLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-100)
        }
        registerIdBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(registerIdTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        authIdButton.snp.makeConstraints{
            $0.right.equalToSuperview().offset(-25)
            $0.bottom.equalTo(registerIdBottom.snp.top).offset(-8)
        }
        
        authCodeLabel.snp.makeConstraints {
            $0.top.equalTo(registerIdBottom.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(24)
        }
        authCodeTextField.snp.makeConstraints {
            $0.top.equalTo(authCodeLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-150)
        }
        authCodeBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(authCodeTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        timerLabel.snp.makeConstraints {
            $0.right.equalTo(authCodeButton.snp.left).offset(-8)
            $0.centerY.equalTo(authCodeButton.snp.centerY)
        }
        authCodeButton.snp.makeConstraints{
            $0.right.equalToSuperview().offset(-25)
            $0.bottom.equalTo(authCodeBottom.snp.top).offset(-8)
        }
        
        changePasswordButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
    }
}
