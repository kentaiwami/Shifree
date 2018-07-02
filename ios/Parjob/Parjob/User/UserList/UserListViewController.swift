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
        let userListDetailVC = UserListDetailViewController()
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
                $0.multivaluedRowToInsertAt = { index in
                    return NameRow() {
                        $0.placeholder = "新規ユーザの名前を入力"
                    }
                }
                
                for user in presenter.getUserList() {
                    $0 <<< ButtonRow() {
                        $0.title = user.name
                        $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userListDetailVC}, onDismiss: {userListDetailVC in userListDetailVC.navigationController?.popViewController(animated: true)})
                        $0.cell.textLabel?.numberOfLines = 0
                    }
                }
        }

        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
//        presenter.updateShiftCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - formでユーザが設定する値
extension UserListViewController {
    var formValues: [String:Any?] {
        return self.form.values()
    }
}

// MARK: - Presenterから呼び出される関数
extension UserListViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
//
//    func success() {
//        ShowStandardAlert(title: "Success", msg: "情報を更新しました", vc: self) {
//            self.navigationController?.popViewController(animated: true)
//        }
//    }
//
//    func showErrorAlert(title: String, msg: String) {
//        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
//    }
}
