//
//  Checkout.swift
//  
//
//  Created by Addey Augustine on 04/11/2020.
//
import Foundation
import UIKit
import WebKit

class CheckoutWebView : WKWebView, WKNavigationDelegate {
    var callback: ((_ url: String)-> Void?)? = nil
    var redirect_url: String? = nil
    
    public init(onDone: @escaping ((_ url: String)-> Void),redirect_url: String) {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"

        let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let userContentController: WKUserContentController = WKUserContentController()
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = userContentController
        userContentController.addUserScript(script)
        webConfiguration.preferences.javaScriptEnabled = true
        self.callback = onDone
        self.redirect_url = redirect_url
        super.init(frame: .zero, configuration: webConfiguration)
        self.scrollView.isScrollEnabled = true
        self.isMultipleTouchEnabled = true
        self.navigationDelegate = self
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @discardableResult
    public func load(checkoutPage : URL) -> WKNavigation? {
         let url : URL = checkoutPage
            let req = URLRequest(url: url)
            return super.load(req)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let host = navigationAction.request.url?.host {
            if self.redirect_url!.contains(host) {
                decisionHandler(.allow)
                callback!(navigationAction.request.url!.absoluteString)
                return
            }
        }
        decisionHandler(.allow)
    }
}
