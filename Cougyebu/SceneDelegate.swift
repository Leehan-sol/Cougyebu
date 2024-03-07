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
        
        if let currentUserEmail = Auth.auth().currentUser?.email {
            let mainVC = MainViewController()
            let mainNavi = UINavigationController(rootViewController: mainVC)
            
            let myPageVM = MyPageViewModel(userEmail: currentUserEmail)
            let myPageVC = MyPageViewController(viewModel: myPageVM)
            let myPageNavi = UINavigationController(rootViewController: myPageVC)
            
            let tabBarVC = UITabBarController()
            tabBarVC.setViewControllers([mainNavi, myPageNavi], animated: false)
            tabBarVC.modalPresentationStyle = .fullScreen
            tabBarVC.tabBar.backgroundColor = .white
            
            if let items = tabBarVC.tabBar.items {
                items[0].title = "Main"
                items[0].image = UIImage(systemName: "folder")
                items[1].title = "My Page"
                items[1].image = UIImage(systemName: "person")
            }
            
            window.rootViewController = tabBarVC
        } else {
            let loginVC = LoginViewController()
            let loginNavi = UINavigationController(rootViewController: loginVC)
            window.rootViewController = loginNavi
        }
        
        window.makeKeyAndVisible()
    }

    
    
    
}

