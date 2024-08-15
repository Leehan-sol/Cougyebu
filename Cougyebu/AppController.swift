//
//  AppController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/30.
//

import UIKit
import RxSwift
import FirebaseAuth

class AppController {
    static let shared = AppController()
    private var disposeBag = DisposeBag()
    
    func start() {
        NotificationCenter.default.rx.notification(.authStateDidChange)
            .subscribe { _ in
                self.updateRootVC(animated: true)
            }.disposed(by: disposeBag)
        
        updateRootVC(animated: false)
    }
    
    private func updateRootVC(animated: Bool) {
        if Auth.auth().currentUser != nil {
            showTabBarController(animated: animated)
        } else {
            showLoginVC()
        }
    }
    
    private func showLoginVC() {
        let loginVM = LoginViewModel()
        let loginVC = LoginViewController(viewModel: loginVM)
        let loginNaviVC = UINavigationController(rootViewController: loginVC)
        
        UIApplication.shared.windows.first?.rootViewController = loginNaviVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    private func showTabBarController(animated: Bool) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        let mainVM = MainViewModel(userEmail: currentUserEmail)
        let mainVC = MainViewController(viewModel: mainVM)
        let mainNaviVC = UINavigationController(rootViewController: mainVC)
        
        let chartVM = ChartViewModel(userEmail: currentUserEmail)
        let chartVC = ChartViewController(viewModel: chartVM)
        
        let myPageVM = MyPageViewModel(userEmail: currentUserEmail)
        let myPageVC = MyPageViewController(viewModel: myPageVM)
        let myPageNaviVC = UINavigationController(rootViewController: myPageVC)
        
        let tabBar = UITabBarController()
        tabBar.setViewControllers([mainNaviVC, chartVC, myPageNaviVC], animated: false)
        tabBar.modalPresentationStyle = .fullScreen
        tabBar.tabBar.backgroundColor = .white
        tabBar.tabBar.tintColor = .black
        
        if let items = tabBar.tabBar.items {
            items[0].title = "Main"
            items[0].image = UIImage(systemName: "folder")
            items[1].title = "Chart"
            items[1].image = UIImage(systemName: "chart.line.uptrend.xyaxis.circle.fill")
            items[2].title = "My Page"
            items[2].image = UIImage(systemName: "person")
        }
        UIApplication.shared.windows.first?.rootViewController = tabBar
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        if animated {
            addAnimation()
        }
    }
    
    func addAnimation() {
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        UIApplication.shared.keyWindow?.layer.add(transition, forKey: kCATransition)
    }
}
