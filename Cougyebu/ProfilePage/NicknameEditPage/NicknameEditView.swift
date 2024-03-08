//
//  NicknameEditView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit

class NicknameEditView: UIView {

    private let nicknameLabel: UILabel = {
         let label = UILabel()
         label.text = "닉네임"
         label.font = UIFont.systemFont(ofSize: 16)
         return label
     }()
     
     let nicknameTextField: UITextField = {
         let tf = UITextField()
         tf.setPlaceholderFontSize(size: 14, text: "변경할 닉네임을 입력하세요.")
         tf.autocapitalizationType = .none
         tf.autocorrectionType = .no
         tf.spellCheckingType = .no
         tf.clearsOnBeginEditing = false
         tf.layer.cornerRadius = 8
         return tf
     }()
     
     private let nicknameBottom: UIView = {
         let view = UIView()
         view.backgroundColor = .systemGray2
         return view
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
     
    let nicknameEditButton: UIButton = {
         let button = UIButton()
         button.setTitle("닉네임 변경", for: .normal)
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
        
        addSubview(nicknameLabel)
        addSubview(nicknameTextField)
        addSubview(nicknameBottom)
        addSubview(nicknameCheckButton)
        addSubview(nicknameEditButton)
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(120)
            $0.left.equalToSuperview().offset(24)
        }
        
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(17)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-70)
        }
        
        nicknameBottom.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(nicknameTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        
        nicknameCheckButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-25)
            $0.bottom.equalTo(nicknameBottom.snp.top).offset(-5)
        }
        
        nicknameEditButton.snp.makeConstraints{
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).offset(-20)
            $0.height.equalTo(45)
        }
        
        
    }
    
    
    
    
    
}

