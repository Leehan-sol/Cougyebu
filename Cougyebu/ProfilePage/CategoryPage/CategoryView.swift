//
//  CategoryView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class CategoryView: UIView {
    let tableView: UITableView = {
        let tv = UITableView()
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
        addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
    
    
    
}

