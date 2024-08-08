//
//  PrivacyViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 06.08.2024.
//

import UIKit
import WebKit

class PrivacyViewController: UIViewController, WKUIDelegate {
    
    private var webView = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        self.webView.uiDelegate = self
        
        let hey = "https://serfodi.ru/privacy.html"
        
        webView.load(URLRequest(url: URL(string: hey)!))
    }
    
    // И этот метод
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
