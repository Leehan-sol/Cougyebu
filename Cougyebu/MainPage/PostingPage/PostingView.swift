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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ko_KR")
        return picker
    }()
    
    private let groupLabel: UILabel = {
        let label = UILabel()
        label.text = "지출 / 수입"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let groupPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .systemGray6
        return picker
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "카테고리"
        label.font = UIFont.boldSystemFont(ofSize: 16)
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
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let contentTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "내용을 입력하세요")
        return tf
    }()
    
    private let contentBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    private let costLabel: UILabel = {
        let label = UILabel()
        label.text = "가격"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let costTextField: UITextField = {
        let tf = UITextField()
        tf.setPlaceholderFontSize(size: 14, text: "가격을 입력하세요")
        return tf
    }()
    
    private let priceBottom: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray2
        return view
    }()
    
    let addButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("추가하기", for: .normal)
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
        
        addSubview(groupLabel)
        addSubview(groupPicker)
        addSubview(dateLabel)
        addSubview(datePicker)
        addSubview(categoryLabel)
        addSubview(categoryPicker)
        addSubview(contentLabel)
        addSubview(contentTextField)
        addSubview(contentBottom)
        addSubview(costLabel)
        addSubview(costTextField)
        addSubview(priceBottom)
        addSubview(addButton)
        
        
        dateLabel.snp.makeConstraints {
            $0.centerY.equalTo(datePicker)
            $0.left.equalToSuperview().offset(40)
        }

        datePicker.snp.makeConstraints {
            $0.top.equalToSuperview().offset(50)
            $0.left.equalTo(groupLabel.snp.right).offset(20)
            $0.right.equalToSuperview().offset(-40)
        }
        
        groupLabel.snp.makeConstraints {
            $0.centerY.equalTo(groupPicker)
            $0.left.equalToSuperview().offset(40)
        }

        groupPicker.snp.makeConstraints {
            $0.top.equalTo(datePicker.snp.bottom).offset(40)
            $0.width.equalTo(130)
            $0.height.equalTo(80)
            $0.right.equalToSuperview().offset(-40)
        }

        categoryLabel.snp.makeConstraints {
            $0.centerY.equalTo(categoryPicker)
            $0.left.equalToSuperview().offset(40)
        }

        categoryPicker.snp.makeConstraints {
            $0.top.equalTo(groupPicker.snp.bottom).offset(40)
            $0.width.equalTo(130)
            $0.height.equalTo(80)
            $0.right.equalToSuperview().offset(-40)
        }

        contentLabel.snp.makeConstraints {
            $0.centerY.equalTo(contentTextField)
            $0.left.equalToSuperview().offset(40)
        }

        contentTextField.snp.makeConstraints {
            $0.top.equalTo(categoryPicker.snp.bottom).offset(50)
            $0.left.equalToSuperview().inset(130)
            $0.right.equalToSuperview().offset(-40)
        }
        
        contentBottom.snp.makeConstraints {
            $0.right.equalToSuperview().inset(40)
            $0.left.equalToSuperview().inset(130)
            $0.bottom.equalTo(contentTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        
        costLabel.snp.makeConstraints {
            $0.centerY.equalTo(costTextField)
            $0.left.equalToSuperview().offset(40)
        }

        costTextField.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom).offset(50)
            $0.left.equalToSuperview().inset(130)
            $0.right.equalToSuperview().offset(-40)
        }
        
        priceBottom.snp.makeConstraints {
            $0.right.equalToSuperview().inset(40)
            $0.left.equalToSuperview().inset(130)
            $0.bottom.equalTo(costTextField.snp.bottom).offset(4)
            $0.height.equalTo(1)
        }
        
        addButton.snp.makeConstraints {
            $0.top.equalTo(priceBottom.snp.bottom).offset(100)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(45)
        }

    }
}
