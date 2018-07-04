//
//  UserListViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

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
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        var count = 0
        let msg = "・既に登録しているユーザを削除して同じ名前のユーザを登録しても、新規登録となるので注意してください。\n・シフト表に同姓同名のユーザが記載されている場合は、並び順をシフト表の記載順と一致させる必要があります。"
        
        form +++
            MultivaluedSection(
            multivaluedOptions: [.Reorder, .Insert, .Delete],
            header: "",
            footer: msg) {
                $0.tag = "textfields"
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "ユーザを追加"
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textAlignment = .left
                    })
                }
                
                let defaultTitle = "タップしてユーザ情報を入力"
                
                $0.multivaluedRowToInsertAt = { index in
                    return ButtonRow() {
                        $0.title = defaultTitle
                        $0.value = defaultTitle
                        $0.tag = String(count) + "_new"
                        count += 1
                    }.cellUpdate({ (cell, row) in
                        cell.textLabel?.textAlignment = .left
                        if row.title! == defaultTitle {
                            cell.textLabel?.textColor = .gray
                        }else {
                            cell.textLabel?.textColor = .black
                        }
                    })
                }
                
                for user in presenter.getUserList() {
                    $0 <<< ButtonRow() {
                        $0.title = String(format: "%@ (%@)", arguments: [user.name, user.role])
                        $0.value = String(format: "%@,%@,%@", arguments: [user.name, user.role, user.code])
                        $0.cell.textLabel?.numberOfLines = 0
                        $0.tag = String(user.code) + "_exist"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textAlignment = .left
                            cell.textLabel?.textColor = .black
                        })
                }
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
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
