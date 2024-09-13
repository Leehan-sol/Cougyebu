//
//  Observable.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import Foundation

class Observable2<T> {

    var value: T {
        didSet {
            self.listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    var listener: ((T) -> Void)?
    
    func bind(_ listener: @escaping (T) -> Void) {
        listener(value)
        self.listener = listener
    }
    
    
}
