//
//  UserListViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol UserListViewInterface: class {
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
}


class UserListViewController: FormViewController, UserListViewInterface {
    fileprivate var presenter: UserListViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = UserListViewPresenter(view: self)
        presenter.setUserList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "ユーザリスト"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        let section = Section()
        
            for user in presenter.getUserList() {
                let textArea = TextAreaRow()
                textArea.value =  String(format: "ユーザ名：%@\nコード：%@\n権限：%@\nパスワード：%@", arguments: [user.name, user.code, user.role, user.password])
                textArea.disabled = true
                textArea.cell.textLabel?.numberOfLines = 0
                section.append(textArea)
            }
        
        form.append(section)
        
        tableView.backgroundView = getEmptyView(msg: EmptyMessage.becauseNoUser.rawValue)
        
        if presenter.getUserList().count == 0 {
            tableView.backgroundView?.isHidden = false
        }else {
            tableView.backgroundView?.isHidden = true
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension UserListViewController {
    func initializeUI() {
        initializeForm()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
