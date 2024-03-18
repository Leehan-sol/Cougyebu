//
//  AppNoticeViewController.swift
//  Cougyebu
//
//  Created by hansol on 2024/03/07.
//

import UIKit
import SnapKit
import WebKit
import NVActivityIndicatorView

class AppNoticeViewController: UIViewController, WKNavigationDelegate {
    private let webView: WKWebView = {
        let wb = WKWebView()
        return wb
    }()
    
    private let indicator = NVActivityIndicatorView(frame: CGRect(x: 162, y: 100, width: 50, height: 50),
                                            type: .lineSpinFadeLoader,
                                            color: .black,
                                            padding: 0)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        webView.navigationDelegate = self
   
        if let url = URL(string: "https://blog.naver.com/ho20128/223382180373") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        setUI()

    }
    
    // MARK: - Methods
    private func setUI() {
        view.addSubview(webView)
        view.addSubview(indicator)
        
        webView.snp.makeConstraints {
            $0.top.left.right.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        indicator.startAnimating()
    }
        
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicator.stopAnimating()
    }
    
}


