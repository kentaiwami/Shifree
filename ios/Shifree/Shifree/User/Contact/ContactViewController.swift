//
//  ContactViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol ContactViewInterface: class {
    var username: String { get }
    func success()
    func showErrorAlert(title: String, msg: String)
}


class ContactViewController: FormViewController, ContactViewInterface {
    
    private var presenter: ContactViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ContactViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "ユーザ名の設定"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        initializeUI()
        UIView.setAnimationsEnabled(true)
    }
    
    var username: String {
        return self.form.values()["username"] as! String
    }
    
    private func initializeForm() {
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "ユーザ名"
                row.tag = "username"
                row.value = presenter.username
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
        }
        .onRowValidationChanged {cell, row in
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
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if isValidateFormValue(form: self.form) {
            presenter.updateUserName()
        }else {
            showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension ContactViewController {
    func success() {
        showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
