//
//  WithdrawalView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

class WithdrawalView: UIView {

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
         let button = UIButton()
         button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
         button.tintColor = .systemGray2
         return button
     }()
     
    let withdrawalButton: UIButton = {
         let button = UIButton()
         button.setTitle("회원탈퇴", for: .normal)
         button.setTitleColor(UIColor.white, for: .normal)
         button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
         button.backgroundColor = .black
         button.layer.cornerRadius = 8
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
    
    
    // MARK: - Methods
    func setUI(){
        self.backgroundColor = .systemBackground
        
        addSubview(passwordLabel)
        addSubview(passwordTextField)
        addSubview(passwordBottom)
        addSubview(passwordButton)
        addSubview(withdrawalButton)
        
        passwordLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.left.equalToSuperview().offset(24)
        }
        
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(passwordLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-70)
        }
        
        passwordBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(passwordTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        
        passwordButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-25)
            $0.bottom.equalTo(passwordBottom.snp.top).offset(-5)
        }
        
        withdrawalButton.snp.makeConstraints{
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
        
        
    }
    
    
    
    
    
}

