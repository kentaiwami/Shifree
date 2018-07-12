//
//  NotificationViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol NotificationViewInterface: class {
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
}


class NotificationViewController: FormViewController, NotificationViewInterface {
    fileprivate var presenter: NotificationViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = NotificationViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "ユーザリスト"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        UIView.setAnimationsEnabled(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension NotificationViewController {
    func initializeUI() {
        initializeForm()
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
