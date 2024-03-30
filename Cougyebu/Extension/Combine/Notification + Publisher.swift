//
//  Notification + Publisher.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/30.
//

import Combine
import UIKit


extension Notification.Name {
    static let authStateDidChange = NSNotification.Name("authStateDidChange")
}


extension NotificationCenter {
    
    static let authStateDidChangePublisher = NotificationCenter.default
        .publisher(for: Notification.Name("authStateDidChange"))
    
}
