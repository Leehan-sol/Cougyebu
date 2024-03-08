//
//  MyPageView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

class MyPageView: UIView {
    
    let heartLabel: UILabel = {
        let label = UILabel()
        label.text = "🖤"
        return label
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "내 닉네임"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let coupleNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "내 짝꿍"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
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
    
    
    func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(heartLabel)
        addSubview(nicknameLabel)
        addSubview(coupleNicknameLabel)
        addSubview(tableView)
        
        heartLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.centerX.equalToSuperview()
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.trailing.equalTo(heartLabel.snp.leading).offset(-10)
        }
        
        coupleNicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.equalTo(heartLabel.snp.trailing).offset(10)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(coupleNicknameLabel.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    
    }
}

