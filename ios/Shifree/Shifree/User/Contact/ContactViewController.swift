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
    var formValue: [String:Any?] { get }
    func success()
    func showErrorAlert(title: String, msg: String)
}


class ContactViewController: FormViewController, ContactViewInterface {
    
    private var presenter: ContactViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ContactViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "お問い合わせ"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        initializeUI()
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeForm() {
        form +++ Section("")
            <<< NameRow(){ row in
                row.title = "氏名"
                row.tag = "name"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
        }
        .onRowValidationChanged {cell, row in
            self.utility.showRowError(row: row)
        }
            
            <<< EmailRow(){ row in
                row.title = "メールアドレス"
                row.tag = "email"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.add(rule: RuleEmail(msg: "メールアドレスの形式が間違っています"))
                row.validationOptions = .validatesOnChange
        }
        .onRowValidationChanged {cell, row in
            self.utility.showRowError(row: row)
        }
        
            <<< TextAreaRow(){ row in
                row.tag = "content"
                row.placeholder = "お問い合わせ内容を入力"
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
            presenter.postContact()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension ContactViewController {
    func success() {
        utility.showStandardAlert(title: "完了", msg: "お問い合わせありがとうございます", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
}
