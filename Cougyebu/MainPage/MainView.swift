//
//  MainView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import FSCalendar
import SnapKit

class MainView: UIView {
    
    let startButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("시작날짜", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return btn
    }()
    
    let waveButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("~", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        return btn
    }()
    
    let lastButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("종료날짜", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        return btn
    }()
    
    let calendar : FSCalendar = {
        let calendar = FSCalendar(frame: .zero)
        calendar.scope = .month
        calendar.firstWeekday = 2
        calendar.placeholderType = .none
        calendar.allowsMultipleSelection = true
        calendar.appearance.todayColor = .clear
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.headerHeight = 55
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.appearance.headerDateFormat = "yy년 MM월"
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.weekdayTextColor = .black
        calendar.backgroundColor = .systemGray6
        calendar.calendarWeekdayView.weekdayLabels.last!.textColor = .red
        return calendar
    }()
    
    let labelStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .equalCentering
        sv.spacing = 5
        return sv
    }()
    
    let incomeLabel: UILabel = {
        let label = UILabel()
        label.text = "수입"
        label.textColor = .systemBlue
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let incomePriceLabel: UILabel = {
        let label = UILabel()
        label.text = "55,000원"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let expenditureLabel: UILabel = {
        let label = UILabel()
        label.text = "지출"
        label.textColor = .systemRed
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let expenditurePriceLabel: UILabel = {
        let label = UILabel()
        label.text = "33,000원"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let sumLabel: UILabel = {
        let label = UILabel()
        label.text = "합계"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let sumPriceLabel: UILabel = {
        let label = UILabel()
        label.text = "22,000원"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return label
    }()
    
    let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "저장된 데이터가 없습니다."
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.separatorStyle = .none
        return tv
    }()
    
    let floatingButton: UIButton = {
        let btn = UIButton()
        let image = UIImage(systemName: "plus.circle")
        let resizedImage = btn.resizeImageButton(image: image, width: 40, height: 40, color: UIColor.black)
        btn.setImage(resizedImage, for: .normal)
        return btn
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    
    func setUI() {
        self.backgroundColor = .systemBackground
        addSubview(tableView)
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(incomeLabel)
        labelStackView.addArrangedSubview(incomePriceLabel)
        labelStackView.addArrangedSubview(expenditureLabel)
        labelStackView.addArrangedSubview(expenditurePriceLabel)
        labelStackView.addArrangedSubview(sumLabel)
        labelStackView.addArrangedSubview(sumPriceLabel)
        addSubview(placeholderLabel)
        addSubview(calendar)
        addSubview(startButton)
        addSubview(waveButton)
        addSubview(lastButton)
        addSubview(floatingButton)
        
        startButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.right.equalTo(waveButton.snp.left).offset(-10)
        }
        
        waveButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.centerX.equalToSuperview()
        }
        
        lastButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(70)
            $0.left.equalTo(waveButton.snp.right).offset(10)
        }
        
        calendar.snp.makeConstraints {
            $0.top.equalTo(lastButton.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().offset(-480)
        }
 
        labelStackView.snp.makeConstraints {
            $0.top.equalTo(waveButton.snp.bottom).offset(10)
            $0.left.right.equalToSuperview().inset(10)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(labelStackView.snp.bottom).offset(10)
            $0.left.right.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview().offset(-100)
        }
        
    }
    
    
}

