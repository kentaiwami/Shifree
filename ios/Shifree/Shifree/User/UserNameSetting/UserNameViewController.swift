//
//  UserNameViewController.swift
//  Shifree
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
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = UserNameViewPresenter(view: self)
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
            self.utility.showRowError(row: row)
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
        if utility.isValidateFormValue(form: self.form) {
            presenter.updateUserName()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension UserNameViewController {
    func success() {
        utility.showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
}
