//
//  SignUpViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol SignUpViewInterface: class {
    var companyCode: String { get }
    var userCode: String { get }
    var userName: String { get }
    var password: String { get }
    
    func navigateCalendar()
    func showErrorAlert(title: String, msg: String)
}

class SignUpViewController: FormViewController, SignUpViewInterface {
    
    private var presenter: SignUpViewPresenter!
    
    var companyCode: String {
        return self.form.values()["companyCode"] as! String
    }

    var userCode: String {
        return self.form.values()["userCode"] as! String
    }

    var userName: String {
        return self.form.values()["userName"] as! String
    }

    var password: String {
        return self.form.values()["password"] as! String
    }
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "サインアップ"
    }
    
    private func initializeUI() {
        form +++ Section("")
            <<< PhoneRow(){
                $0.title = "企業コード"
                $0.tag = "companyCode"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged {cell, row in
                    self.utility.showRowError(row: row)
                }
            
            <<< PhoneRow(){
                $0.title = "ユーザコード"
                $0.tag = "userCode"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                }
                .onRowValidationChanged {cell, row in
                    self.utility.showRowError(row: row)
                }
            <<< TextRow(){ row in
                row.title = "ユーザ名"
                row.tag = "userName"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
            }
            
            <<< PasswordRow(){
                $0.title = "パスワード"
                $0.tag = "password"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
            }
        
        form +++ Section()
            <<< ButtonRow(){
                $0.title = "サインアップ"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                }
                .onCellSelection {  cell, row in
                    self.signUpButtonTapped()
            }
    }
    
    private func signUpButtonTapped() {
        if utility.isValidateFormValue(form: form) {
            presenter.signUpButtonTapped()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }
    
    private func initializePresenter() {
        presenter = SignUpViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数一覧
extension SignUpViewController {
    func navigateCalendar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topVC = storyboard.instantiateInitialViewController()
        topVC?.modalTransitionStyle = .crossDissolve
        self.present(topVC!, animated: true, completion: nil)
    }
    
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
}
