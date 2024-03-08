//
//  CategoryViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/08.
//

import UIKit

class CategoryViewController: UIViewController {
    private let user: Observable<User>?
    
    init(user: Observable<User>?) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
