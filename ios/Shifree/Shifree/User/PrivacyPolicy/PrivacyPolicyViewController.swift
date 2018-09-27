//
//  PrivacyPolicyViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints

protocol PrivacyPolicyViewInterface: class {
}


class PrivacyPolicyViewController: UIViewController, PrivacyPolicyViewInterface {
    fileprivate var presenter: PrivacyPolicyViewPresenter!
    fileprivate var webView: UIWebView!
    fileprivate let indicator = Indicator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PrivacyPolicyViewPresenter(view: self)
        initializeWebView()
    }
    
    private func initializeWebView() {
        webView = UIWebView()
        webView.delegate = self
        self.view.addSubview(webView)
        webView.edges(to: self.view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "プライバシーポリシー"
        webView.loadRequest(presenter.getURLRequest())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


extension PrivacyPolicyViewController: UIWebViewDelegate {
    func webViewDidStartLoad(_ webView: UIWebView) {
        indicator.start()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        indicator.stop()
    }
}


// MARK: - Presenterから呼び出される関数
extension PrivacyPolicyViewController {
}
