//
//  LoginView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit

class LoginView: UIView {
    
    // MARK: - UI Properties
    
    let titleImage: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Title")
        return imgView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "커계부"
        label.font = UIFont.boldSystemFont(ofSize: 35)
        label.textColor = .black
        return label
    }()
    
    let idView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGray2.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let idTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.keyboardType = .emailAddress
        tf.clearsOnBeginEditing = false
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    let idLabel: UILabel = {
        let label = UILabel()
        label.text = "아이디를 입력하세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray2
        return label
    }()
    
    let pwView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.systemGray2.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    let pwTextField: UITextField = {
        let tf = UITextField()
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.spellCheckingType = .no
        tf.isSecureTextEntry = true
        tf.clearsOnBeginEditing = false
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    
    let pwLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호를 입력하세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .systemGray2
        return label
    }()
    
    let showPwButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        btn.tintColor = .systemGray2
        return btn
    }()
    
    let loginButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("로그인", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    let findIdButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("아이디 찾기", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    let findPwButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("비밀번호 찾기", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    let registerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("회원가입", for: .normal)
        btn.setTitleColor(.systemGray, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return btn
    }()
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.spacing = 16
        sv.axis = .horizontal
        sv.alignment = .fill
        return sv
    }()
    
    lazy var idLabelCenterY: NSLayoutConstraint = {
        let constraint = idLabel.centerYAnchor.constraint(equalTo: idTextField.centerYAnchor)
        return constraint
    }()
    
    lazy var pwLabelCenterY: NSLayoutConstraint = {
        let constraint = pwLabel.centerYAnchor.constraint(equalTo: pwTextField.centerYAnchor)
        return constraint
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Methods
    func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(titleImage)
        
        addSubview(idView)
        idView.addSubview(idTextField)
        idView.addSubview(idLabel)
        
        addSubview(pwView)
        pwView.addSubview(pwTextField)
        pwView.addSubview(pwLabel)
        pwView.addSubview(showPwButton)
        
        addSubview(loginButton)
        
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(findIdButton)
        buttonStackView.addArrangedSubview(findPwButton)
        buttonStackView.addArrangedSubview(registerButton)
        
        idLabel.translatesAutoresizingMaskIntoConstraints = false
        pwLabel.translatesAutoresizingMaskIntoConstraints = false
        
        titleImage.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(40)
            $0.bottom.equalTo(idView.snp.top).offset(-40)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(50)
        }
        
        idView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(280)
            $0.left.right.equalToSuperview().inset(24)
        }
        idTextField.snp.makeConstraints {
            $0.edges.equalTo(idView)
            $0.height.equalTo(48)
        }
        idLabel.snp.makeConstraints { make in
            make.left.equalTo(idView.snp.left).offset(8)
            make.right.equalTo(idView.snp.right).offset(-8)
            idLabelCenterY.isActive = true
        }
        
        pwView.snp.makeConstraints {
            $0.top.equalTo(idView.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(24)
        }
        pwTextField.snp.makeConstraints {
            $0.top.bottom.left.equalTo(pwView)
            $0.right.equalTo(pwView.snp.right).offset(-40)
            $0.height.equalTo(48)
        }
        pwLabel.snp.makeConstraints {
            $0.left.equalTo(pwView.snp.left).offset(8)
            $0.right.equalTo(pwView.snp.right).offset(-8)
            pwLabelCenterY.isActive = true
        }
        showPwButton.snp.makeConstraints {
            $0.right.equalTo(pwView.snp.right).offset(-8)
            $0.centerY.equalTo(pwView)
        }
        
        loginButton.snp.makeConstraints {
            $0.top.equalTo(pwView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(45)
        }
        
        buttonStackView.snp.makeConstraints{
            $0.top.equalTo(loginButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
        }
    }
    
}


