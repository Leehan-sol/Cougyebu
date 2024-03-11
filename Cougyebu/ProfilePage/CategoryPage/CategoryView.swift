//
//  CategoryView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class CategoryView: UIView {
    
    let buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.spacing = 20
        return sv
    }()
    
    let incomeButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("수입", for: .normal)
        btn.backgroundColor = .systemGray6
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 5.0
        return btn
    }()
    
    let expenditureButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("지출", for: .normal)
        btn.backgroundColor = .black
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 5.0
        return btn
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return tv
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
        addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(incomeButton)
        buttonStackView.addArrangedSubview(expenditureButton)
        addSubview(tableView)
        
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(100)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(buttonStackView.snp.bottom).offset(10)
            $0.left.right.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    
    
}

