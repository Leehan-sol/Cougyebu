//
//  ConnectView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit

class ConnectView: UIView {
    
    // MARK: - UI Properties
    let coupleEmailLabel: UILabel = {
        let label = UILabel()
        label.text = "커플 이메일"
        return label
    }()
    
    let coupleEmailTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "연결할 이메일을 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        return tf
    }()
    
    private let coupleEmailBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let coupleCodeLabel: UILabel = {
        let label = UILabel()
        label.text = "커플 코드"
        return label
    }()
    
    let coupleCodeTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "받으신 코드를 입력하세요.")
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    let coupleCodeBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let connectButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("연결하기", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 8
        btn.layer.masksToBounds = true
        return btn
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(coupleEmailLabel)
        addSubview(coupleEmailTextField)
        addSubview(coupleEmailBottom)
        addSubview(coupleCodeLabel)
        addSubview(coupleCodeTextField)
        addSubview(coupleCodeBottom)
        addSubview(connectButton)
        
        coupleEmailLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(95)
            $0.left.equalToSuperview().offset(24)
        }
        coupleEmailTextField.snp.makeConstraints {
            $0.top.equalTo(coupleEmailLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
        }
        coupleEmailBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(coupleEmailTextField.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        coupleCodeLabel.snp.makeConstraints {
            $0.top.equalTo(coupleEmailBottom.snp.bottom).offset(20)
            $0.left.equalToSuperview().offset(24)
        }
        coupleCodeTextField.snp.makeConstraints {
            $0.top.equalTo(coupleCodeLabel.snp.bottom).offset(15)
            $0.left.equalToSuperview().offset(24)
        }
        coupleCodeBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(coupleCodeTextField.snp.bottom).offset(3)
            $0.height.equalTo(1)
        }
        
        connectButton.snp.makeConstraints {
            $0.left.right.equalTo(self).inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
        
    }
}

