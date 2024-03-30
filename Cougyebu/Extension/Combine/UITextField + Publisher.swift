//
//  UITextField + Publisher.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Combine
import UIKit

extension UITextField {
    
    func setPlaceholderFontSize(size: CGFloat, text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: size)
        ]
        self.attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }
    
}


extension UITextField {
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .compactMap(\.text)
            .eraseToAnyPublisher()
    }
    
}