//
//  RegisterView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit

class RegisterView: UIView {
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let idTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "유효한 이메일 주소를 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.keyboardType = .emailAddress
        tf.clearsOnBeginEditing = false
        return tf
    }()
    let sendEmailButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("인증메일전송", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return btn
    }()
    private let idBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let authLabel: UILabel = {
        let label = UILabel()
        label.text = "인증번호"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let authTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "받으신 인증번호를 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.clearsOnBeginEditing = false
        tf.keyboardType = .numberPad
        return tf
    }()
    let authButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("인증확인", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return btn
    }()
    let timerLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    private let authBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "사용할 닉네임을 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.clearsOnBeginEditing = false
        return tf
    }()
    let nicknameCheckButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("중복확인", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 12
        btn.layer.masksToBounds = true
        btn.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        return btn
    }()
    private let nicknameBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let pwTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "특수문자, 숫자 포함 8자 이상")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        return tf
    }()
    let showPwButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    private let pwBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let pwCheckLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    let pwCheckTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "특수문자, 숫자 포함 8자 이상")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.textContentType = .password
        tf.isSecureTextEntry = true
        return tf
    }()
    let showPwCheckButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    let pwCheckBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        btn.backgroundColor = .systemGray6
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect){
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(idLabel)
        addSubview(idTextField)
        addSubview(sendEmailButton)
        addSubview(idBottom)
        
        addSubview(authLabel)
        addSubview(authTextField)
        addSubview(authButton)
        addSubview(timerLabel)
        addSubview(authBottom)
        
        addSubview(nicknameLabel)
        addSubview(nicknameTextField)
        addSubview(nicknameCheckButton)
        addSubview(nicknameBottom)
        
        addSubview(pwLabel)
        addSubview(pwTextField)
        addSubview(showPwButton)
        addSubview(pwBottom)
        
        addSubview(pwCheckLabel)
        addSubview(pwCheckTextField)
        addSubview(showPwCheckButton)
        addSubview(pwCheckBottom)
        
        addSubview(registerButton)
        
        idLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(95)
            $0.left.equalToSuperview().offset(24)
        }
        idTextField.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalTo(sendEmailButton.snp.left).offset(-10)
        }
        sendEmailButton.snp.makeConstraints {
            $0.centerY.equalTo(idTextField)
            $0.right.equalToSuperview().offset(-24)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        idBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(sendEmailButton.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        authLabel.snp.makeConstraints {
            $0.top.equalTo(idBottom.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        authTextField.snp.makeConstraints {
            $0.top.equalTo(authLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalTo(authButton.snp.left).offset(-10)
        }
        authButton.snp.makeConstraints {
            $0.centerY.equalTo(authTextField)
            $0.right.equalToSuperview().offset(-24)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        timerLabel.snp.makeConstraints {
            $0.right.equalTo(authButton.snp.left).offset(-8)
            $0.centerY.equalTo(authButton.snp.centerY)
        }
        authBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(authButton.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalTo(authBottom.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalTo(sendEmailButton.snp.left).offset(-10)
        }
        nicknameCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(nicknameTextField)
            $0.right.equalToSuperview().offset(-24)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        nicknameBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(nicknameCheckButton.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        pwLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameBottom.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        pwTextField.snp.makeConstraints {
            $0.top.equalTo(pwLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-60)
        }
        showPwButton.snp.makeConstraints {
            $0.centerY.equalTo(pwTextField)
            $0.right.equalToSuperview().offset(-30)
        }
        pwBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(showPwButton.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        pwCheckLabel.snp.makeConstraints {
            $0.top.equalTo(pwBottom.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        pwCheckTextField.snp.makeConstraints {
            $0.top.equalTo(pwCheckLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-60)
        }
        showPwCheckButton.snp.makeConstraints {
            $0.centerY.equalTo(pwCheckTextField)
            $0.right.equalToSuperview().offset(-30)
        }
        pwCheckBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(showPwCheckButton.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        registerButton.snp.makeConstraints {
            $0.top.equalTo(pwCheckBottom.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(45)
        }
        
    }
    
    
    
}
