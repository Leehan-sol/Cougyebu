//
//  MainTableViewCell.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/09.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = .right
        return label
    }()
    
    let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        contentView.addSubview(dateLabel)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(categoryLabel)
        stackView.addArrangedSubview(contentLabel)
        stackView.addArrangedSubview(priceLabel)

        dateLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView).inset(10)
            $0.left.equalTo(contentView).inset(20)
        }
        stackView.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView).inset(10)
            $0.left.equalTo(dateLabel.snp.right).offset(20)
            $0.right.equalTo(contentView).inset(20)
        }
        
    }
}
