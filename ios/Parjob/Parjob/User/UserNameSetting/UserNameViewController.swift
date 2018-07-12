//
//  UserNameViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol UserNameViewInterface: class {
    var username: String { get }
    func success()
    func showErrorAlert(title: String, msg: String)
}


class UserNameViewController: FormViewController, UserNameViewInterface {
    
    private var presenter: UserNameViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = UserNameViewPresenter(view: self)
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "ユーザ名の設定"
    }
    
    var username: String {
        return self.form.values()["username"] as! String
    }
    
    private func initializeForm() {
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "UserName"
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
        if IsValidateFormValue(form: self.form) {
            presenter.updateUserName()
        }else {
            ShowStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension UserNameViewController {
    func success() {
        ShowStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
