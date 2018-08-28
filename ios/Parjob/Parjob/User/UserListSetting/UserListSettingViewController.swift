//
//  UserListSettingViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol UserListSettingViewInterface: class {
    var formValues: [String] { get }
    
    func success()
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
}


class UserListSettingViewController: FormViewController, UserListSettingViewInterface {
    fileprivate var presenter: UserListSettingViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = UserListSettingViewPresenter(view: self)
        presenter.setUserList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "ユーザリストの設定"
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
                    }).onCellSelection({ (cell, row) in
                        let value = self.getUsernameRoleFromCellTitle(title: row.title!)
                        self.TapUserCell(username: value.username, role: value.role, isNew: true, row: row, code: "")
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
                        }).onCellSelection({ (cell, row) in
                            let value = self.getUsernameRoleFromCellTitle(title: row.title!)
                            self.TapUserCell(username: value.username, role: value.role, isNew: false, row: row, code: user.code)
                        })
                }
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func TapUserCell(username: String, role: String, isNew: Bool, row: ButtonRow, code: String) {
        let vc = UserListSettingDetailViewController()
        vc.setAllData(username: username, role: role, isNew: isNew)
        
        let popUp = PopupDialog(viewController: vc)
        let buttonOK = DefaultButton(title: "OK"){
            if isValidateFormValue(form: vc.form) {
                let detaiVCValues = vc.form.values()
                row.title = String(format: "%@ (%@)", arguments: [detaiVCValues["username"] as! String, detaiVCValues["role"] as! String])
                row.value = String(format: "%@,%@,%@", arguments: [detaiVCValues["username"] as! String, detaiVCValues["role"] as! String, code])
                row.updateCell()
            }else {
                showStandardAlert(title: "エラー", msg: "入力されていない項目があります。\n再度、やり直してください。", vc: self, completion: nil)
            }
        }
        let buttonCancel = CancelButton(title: "キャンセル"){}
        
        popUp.addButton(buttonOK)
        popUp.addButton(buttonCancel)
        present(popUp, animated: true, completion: nil)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateUserList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - 可読性のために関数化
extension UserListSettingViewController {
    fileprivate func getUsernameRoleFromCellTitle(title: String) -> (username: String, role: String) {
        let usernameMatch = getMatchStrings(targetString: title, pattern: ".* ")
        let roleMatch = getMatchStrings(targetString: title, pattern: "\\(.*\\)")
        
        if usernameMatch.count == 0 {
            return ("", "")
        }
        
        let username = usernameMatch[0].substring(to: usernameMatch[0].index(before: usernameMatch[0].endIndex))
        var role = roleMatch[0].substring(to: roleMatch[0].index(before: roleMatch[0].endIndex))
        role = role.replacingOccurrences(of:"(", with:"")
        role = role.replacingOccurrences(of:")", with:"")
        return (username, role)
    }
}


// MARK: - formでユーザが設定する値
extension UserListSettingViewController {
    var formValues: [String] {
        var results: [String] = []
        
        for baseRow in form.allRows {
            if let tmp = baseRow.baseValue as? String {
                results.append(tmp)
            }
        }
        return results
    }
}

// MARK: - Presenterから呼び出される関数
extension UserListSettingViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }

    func success() {
        showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }

    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
