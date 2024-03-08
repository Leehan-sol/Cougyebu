//
//  PostingView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit
import SnapKit

class PostingView: UIView {
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        return label
    }()
    
    let categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemGray6
        return picker
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        return label
    }()
    
    let contentTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "내용을 입력하세요"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.text = "가격"
        return label
    }()
    
    let priceTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "가격을 입력하세요"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad
        return tf
    }()
    
    let addButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("추가", for: .normal)
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
        
    }
    
    private func setUI() {
        self.backgroundColor = .white
        
        
        addSubview(dateLabel)
        addSubview(datePicker)
        addSubview(categoryLabel)
        addSubview(categoryPicker)
        addSubview(contentLabel)
        addSubview(contentTextField)
        addSubview(priceLabel)
        addSubview(priceTextField)
        addSubview(addButton)
        
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(datePicker)
            $0.left.equalToSuperview().offset(40)
        }

        datePicker.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.left.equalTo(dateLabel.snp.right).offset(20)
            $0.right.equalToSuperview().offset(-40)
        }

        categoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryPicker)
            $0.left.equalToSuperview().offset(40)
        }

        categoryPicker.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(40)
            $0.width.equalTo(150)
            $0.height.equalTo(100)
            $0.right.equalToSuperview().offset(-20)
        }

        contentLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentTextField)
            $0.left.equalToSuperview().offset(40)
        }

        contentTextField.snp.makeConstraints {
            $0.top.equalTo(categoryPicker.snp.bottom).offset(40)
            $0.left.equalTo(contentLabel.snp.right).offset(40)
            $0.right.equalToSuperview().offset(-20)
        }

        priceLabel.snp.makeConstraints {
            $0.centerY.equalTo(priceTextField)
            $0.left.equalToSuperview().offset(40)
        }

        priceTextField.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom).offset(40)
            $0.left.equalTo(priceLabel.snp.right).offset(40)
            $0.right.equalToSuperview().offset(-20)
        }
        
        addButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().offset(-60)
            $0.height.equalTo(45)
        }

    }
}
