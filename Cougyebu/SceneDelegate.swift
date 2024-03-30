//
//  SceneDelegate.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//


import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
          guard let windowScene = (scene as? UIWindowScene) else { return }
          let window = UIWindow(windowScene: windowScene)
          self.window = window
          
        AppController.shared.start()
      }

    
    
}

