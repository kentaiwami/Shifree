//
//  UserTopViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol UserTopViewInterface: class {
//    func navigateCalendar()
}

class UserTopViewController: FormViewController, UserTopViewInterface {
    
    private var presenter: UserTopViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "User"
    }
    
    func initializeUI() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }

        form +++ Section("")
            <<< PhoneRow(){
                $0.title = "CompanyCode"
                $0.tag = "companyCode"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
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
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            
            <<< PhoneRow(){
                $0.title = "UserCode"
                $0.tag = "userCode"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
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
                            }
                            row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                        }
                    }
                }
            <<< TextRow(){ row in
                row.title = "UserName"
                row.tag = "userName"
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
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
            
            <<< PasswordRow(){
                $0.title = "PassWord"
                $0.tag = "password"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
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
                        }
                        row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                    }
                }
            }
        
        form +++ Section()
            <<< ButtonRow(){
                $0.title = "Sign Up"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                }
                .onCellSelection {  cell, row in
                    
            }
    }
    
    func initializePresenter() {
        presenter = UserTopViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}