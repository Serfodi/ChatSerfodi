//
//  PrivacyViewController.swift
//  ChatSerfodi
//
//  Created by Сергей Насыбуллин on 06.08.2024.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKUIDelegate {
    
    enum WebPage: String {
        case privacyHTML
        case termsHTML
        case licenseHTML
    }
    
    private var webView = WKWebView()
    private var url: URL
    
    init(page: WebPage) {
        let urlString = "https://serfodi.ru/\(page.rawValue.localized()).html"
        self.url = URL(string: urlString)!
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        webView.frame = view.bounds
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.webView.uiDelegate = self
        webView.load(URLRequest(url: url))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("PrivacyViewControllerModalClosed"), object: nil)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
