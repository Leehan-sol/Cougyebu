//
//  String +.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation

extension String {
    
    var isConsonant: Bool {
        guard let scalar = UnicodeScalar(self)?.value else {
            return false
        }
        let consonantScalarRange: ClosedRange<UInt32> = 12593...12622
        return consonantScalarRange ~= scalar
    }
    
    // 아이디 정규 표현식
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        return emailTest.evaluate(with: self)
    }
    
    // 비밀번호 정규 표현식 (8자 이상, 특수문자, 숫자 포함)
    func isValidPassword() -> Bool {
        let regularExpression = "^(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$"
        let passwordValidation = NSPredicate(format: "SELF MATCHES %@", regularExpression)

        return passwordValidation.evaluate(with: self)
    }
    
    func removeComma(from string: String) -> String {
        return string.replacingOccurrences(of: ",", with: "")
    }
    
    
    
}

