//
//  MainView.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit

class MainView: UIView {
    
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
        addSubview(floatingButton)
        
        tableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview()
        }
        
        floatingButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-30)
            $0.bottom.equalToSuperview().offset(-100)
        }
    
        
    }
    
    
}

