//
//  PasswordViewController.swift
//  Shifree
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
    
    private var presenter: PasswordViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PasswordViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "パスワードの設定"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        initializeUI()
        UIView.setAnimationsEnabled(true)
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
                self.utility.showRowError(row: row)
            }
        
            <<< PasswordRow() {
                $0.title = "新しいパスワード"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "new"
            }
            .onRowValidationChanged { cell, row in
                self.utility.showRowError(row: row)
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if utility.isValidateFormValue(form: self.form) {
            presenter.updatePassword()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
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
        utility.showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
}
