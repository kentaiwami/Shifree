//
//  PasswordViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol PasswordViewInterface: class {
    var nowPassword: String { get }
    var newPassword: String { get }
    
    func success()
    func showErrorAlert(title: String, msg: String)
}


class PasswordViewController: FormViewController, PasswordViewInterface {
    
    fileprivate var presenter: PasswordViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PasswordViewPresenter(view: self)
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "パスワードの設定"
    }
    
    private func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("")
            <<< PasswordRow() {
                $0.title = "現在のパスワード"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "now"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                            $0.cell.contentView.backgroundColor = .red
                            $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                            })
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
            <<< PasswordRow() {
                $0.title = "新しいパスワード"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "new"
            }
            .onRowValidationChanged { cell, row in
                let rowIndex = row.indexPath!.row
                while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                    row.section?.remove(at: rowIndex + 1)
                }
                if !row.isValid {
                    for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                        let labelRow = LabelRow() {
                            $0.title = err
                            $0.cell.height = { 30 }
                            $0.cell.contentView.backgroundColor = .red
                            $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textColor = .white
                            })
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if isValidateFormValue(form: self.form) {
            presenter.updatePassword()
        }else {
            showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self, completion: nil)
        }
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - formでユーザが設定する値の一覧
extension PasswordViewController {
    var nowPassword: String {
        return self.form.values()["now"] as! String
    }
    
    var newPassword: String {
        return self.form.values()["new"] as! String
    }
}

// MARK: - Presenterから呼び出される関数
extension PasswordViewController {
    func success() {
        showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
