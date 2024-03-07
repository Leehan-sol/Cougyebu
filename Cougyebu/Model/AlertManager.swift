//
//  AlertManager.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit

struct AlertManager {
    static func showAlertOneButton(from viewController: UIViewController, title: String, message: String?, buttonTitle: String, completion: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            completion?()
        }
        
        alertController.addAction(action)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertTwoButton(from viewController: UIViewController, title: String, message: String?, button1Title: String, button2Title: String, completion1: (() -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action1 = UIAlertAction(title: button1Title, style: .default) { _ in
            completion1?()
        }
        let action2 = UIAlertAction(title: button2Title, style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func showAlertWithTwoTF(from viewController: UIViewController, title: String, message: String?, placeholder1: String, placeholder2: String, button1Title: String, button2Title: String, completion1: ((_ text1: String?, _ text2: String?) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = placeholder1
        }
        
        alertController.addTextField { textField in
            textField.placeholder = placeholder2
        }
        
        let action1 = UIAlertAction(title: button1Title, style: .default) { _ in
            let text1 = alertController.textFields?[0].text
            let text2 = alertController.textFields?[1].text
            completion1?(text1, text2)
        }
        
        let action2 = UIAlertAction(title: button2Title, style: .cancel)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        
        viewController.present(alertController, animated: true, completion: nil)
    }

    
}

