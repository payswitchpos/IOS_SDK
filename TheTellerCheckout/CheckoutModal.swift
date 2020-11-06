//
//  CheckoutModal.swift
//  TheTellerCheckout
//
//  Created by Addey Augustine on 06/11/2020.
//  Copyright © 2020 TheTeller. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class PopupModal: UIView {
    
    fileprivate var url: URL? = nil
    fileprivate var redirect: String? = nil
    fileprivate var finish: ((_ json: [String: Any]?, _ error: Error?) -> Void)? = nil
    fileprivate let modalHeader: UIButton = {
        let header = UIButton()
          header.backgroundColor = .white
          header.layer.cornerRadius = 24
        return header
    }()
    fileprivate let getCloseButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.red, for: .normal)
        button.setTitle("X", for: .normal)
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 50
        button.frame  = CGRect(x:5, y:5, width:25, height:25)
        return button
    }()
    fileprivate let container: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .white
        v.layer.cornerRadius = 24
        return v
    }()
    @objc fileprivate func animationIn(){
        self.container.transform = CGAffineTransform(translationX: 0, y: -self.frame.height)
        self.alpha = 1
        UIView.animate(withDuration: 0.5,delay: 0.1,usingSpringWithDamping: 0.7,initialSpringVelocity: 1,options: .curveEaseIn, animations: {
            self.container.transform = .identity
            self.alpha = 1
        })
    }
    public func handleDone(url: String){
        let reason = getQueryStringParameter(url: url,param: "status")
        let code = getQueryStringParameter(url: url,param: "code")
        let status = getQueryStringParameter(url: url,param: "code")
        let transaction_id = getQueryStringParameter(url: url,param: "transaction_id")
        let  data: [String: Any] = ["status":status!,"reason":reason!,"code":code!, "transaction_id": transaction_id!]
        self.finish!(data,nil)
    }
    public init(urlRequest: URL, redirectUrl: String, finish: @escaping ((_ json: [String: Any]?, _ error: Error?) -> Void)) {
        self.url = urlRequest
        self.redirect = redirectUrl
        self.finish = finish
        super.init(frame: .zero)
        self.backgroundColor = .gray
        self.frame = UIScreen.main.bounds
        let webView = CheckoutWebView(onDone: handleDone, redirect_url: self.redirect!)
        webView.load(checkoutPage:self.url!)
        getCloseButton.addTarget(self, action: #selector(self.oncDismiss), for: .touchUpInside)
        modalHeader.addSubview(getCloseButton)
        let stack = UIStackView(arrangedSubviews: [modalHeader,webView])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        self.addSubview(container)
        container.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        container.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        container.widthAnchor.constraint(equalTo: self.widthAnchor,multiplier: 0.85).isActive = true
        container.heightAnchor.constraint(equalTo: self.heightAnchor,multiplier:  0.8).isActive = true
        container.addSubview(stack)
        stack.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        stack.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        stack.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        animationIn()

    }
    @objc fileprivate func oncDismiss(_ sender: UIButton){
        self.finish!(["code":"undefined","transaction_id":"undefined","status":"undefined","reason":"undefined"],nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder): has not been implemented")
    }
    fileprivate func getQueryStringParameter(url: String, param: String) -> String? {
      guard let url = URLComponents(string: url) else { return nil }
      return url.queryItems?.first(where: { $0.name == param })?.value
    }
}
