//
//  WageViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol WageViewInterface: class {
    var daytimeStart: String { get }
    var daytimeEnd: String { get }
    var nightStart: String { get }
    var nightEnd: String { get }
    var daytimeWage: Int { get }
    var nightWage: Int { get }
    
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class WageViewController: FormViewController, WageViewInterface {
    
    fileprivate var presenter: WageViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = WageViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "時給の設定"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        UIView.setAnimationsEnabled(true)
        
        presenter.setUserWage()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        let wageTime = get24hourTime()
        
        form +++ Section("日中")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = wageTime
                $0.value = presenter.getUserWage().daytimeStart
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytimeStart"
                $0.cell.detailTextLabel?.textColor = UIColor.black
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
            
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = wageTime
                $0.value = presenter.getUserWage().daytimeEnd
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "daytimeEnd"
                $0.cell.detailTextLabel?.textColor = UIColor.black
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
            
            <<< IntRow(){
                $0.title = "時給"
                $0.value = presenter.getUserWage().daytimeWage
                $0.tag = "daytimeWage"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
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
        
        form +++ Section("深夜")
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = wageTime
                $0.value = presenter.getUserWage().nightStart
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "nightStart"
                $0.cell.detailTextLabel?.textColor = UIColor.black
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
            
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = wageTime
                $0.value = presenter.getUserWage().nightEnd
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "nightEnd"
                $0.cell.detailTextLabel?.textColor = UIColor.black
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
            
            <<< IntRow(){
                $0.title = "時給"
                $0.value = presenter.getUserWage().nightWage
                $0.tag = "nightWage"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
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
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if isValidateFormValue(form: self.form) {
            presenter.updateUserWage()
        }else {
            showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - formでユーザが設定する値の一覧
extension WageViewController {
    var daytimeStart: String {
        return self.form.values()["daytimeStart"] as! String
    }
    
    var daytimeEnd: String {
        return self.form.values()["daytimeEnd"] as! String
    }
    
    var nightStart: String {
        return self.form.values()["nightStart"] as! String
    }
    
    var nightEnd: String {
        return self.form.values()["nightEnd"] as! String
    }
    
    var daytimeWage: Int {
        return self.form.values()["daytimeWage"] as! Int
    }
    
    var nightWage: Int {
        return self.form.values()["nightWage"] as! Int
    }
}



// MARK: - Presenterから呼び出される関数
extension WageViewController {
    
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
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
