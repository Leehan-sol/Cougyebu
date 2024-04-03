//
//  PasswordEditView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//


import UIKit
import SnapKit

class PasswordEditView: UIView {
    
    private let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "사용중인 비밀번호를 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        tf.clearsOnBeginEditing = false
        tf.layer.cornerRadius = 8
        return tf
    }()
    
    private let passwordBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let passwordButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    
    private let newPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "새로운 비밀번호"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        tf.clearsOnBeginEditing = false
        tf.layer.cornerRadius = 8
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.setPlaceholderFontSize(size: 14, text: "특수문자, 숫자 포함 8자 이상")
        return tf
    }()
    
    private let newBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let newPasswordButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    
    private let changPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호 확인"
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    let changePasswordTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "변경할 비밀번호를 한번 더 입력하세요.")
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        tf.clearsOnBeginEditing = false
        tf.layer.cornerRadius = 8
        return tf
    }()
    
    private let changBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let checkPasswordButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    
    let changePasswordButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("비밀번호 변경", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setUI(){
        self.backgroundColor = .systemBackground
        
        addSubview(passwordLabel)
        addSubview(passwordTextField)
        addSubview(passwordBottom)
        addSubview(passwordButton)
        
        addSubview(newPasswordLabel)
        addSubview(newPasswordTextField)
        addSubview(newBottom)
        addSubview(newPasswordButton)
        
        addSubview(changPasswordLabel)
        addSubview(changePasswordTextField)
        addSubview(changBottom)
        addSubview(checkPasswordButton)
        
        addSubview(changePasswordButton)
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(120)
            $0.left.equalTo(self.snp.left).offset(24)
        }
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(17)
            $0.left.equalTo(self.snp.left).offset(24)
            $0.right.equalTo(self.snp.right).offset(-55)
        }
        passwordBottom.snp.makeConstraints {
            $0.left.right.equalTo(self).inset(24)
            $0.bottom.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        passwordButton.snp.makeConstraints{
            $0.right.equalTo(self.snp.right).offset(-25)
            $0.bottom.equalTo(passwordBottom.snp.top).offset(-5)
        }
        
        newPasswordLabel.snp.makeConstraints {
            $0.top.equalTo(passwordBottom.snp.bottom).offset(24)
            $0.left.equalTo(self.snp.left).offset(24)
        }
        newPasswordTextField.snp.makeConstraints {
            $0.top.equalTo(newPasswordLabel.snp.bottom).offset(17)
            $0.left.equalTo(self.snp.left).offset(24)
            $0.right.equalTo(self.snp.right).offset(-55)
        }
        newBottom.snp.makeConstraints {
            $0.left.right.equalTo(self).inset(24)
            $0.bottom.equalTo(newPasswordTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        newPasswordButton.snp.makeConstraints {
            $0.right.equalTo(self.snp.right).offset(-25)
            $0.bottom.equalTo(newBottom.snp.top).offset(-5)
        }
        
        
        changPasswordLabel.snp.makeConstraints {
            $0.top.equalTo(newBottom.snp.bottom).offset(24)
            $0.left.equalTo(self.snp.left).offset(24)
        }
        changePasswordTextField.snp.makeConstraints {
            $0.top.equalTo(changPasswordLabel.snp.bottom).offset(17)
            $0.left.equalTo(self.snp.left).offset(24)
            $0.right.equalTo(self.snp.right).offset(-55)
        }
        changBottom.snp.makeConstraints {
            $0.left.right.equalTo(self).inset(24)
            $0.bottom.equalTo(changePasswordTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        checkPasswordButton.snp.makeConstraints {
            $0.right.equalTo(self.snp.right).offset(-25)
            $0.bottom.equalTo(changBottom.snp.top).offset(-5)
        }
        
        changePasswordButton.snp.makeConstraints{
            $0.left.right.equalTo(self).inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
    }
    
    
    
    
    
}
