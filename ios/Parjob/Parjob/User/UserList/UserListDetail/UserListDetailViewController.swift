//
//  UserListDetailViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/03.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import TinyConstraints

class UserListDetailViewController: FormViewController {

    var username: String = ""
    var role: String = ""
    var isNew: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "ユーザ名"
                row.value = username
                row.tag = "username"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
                
                if isNew {
                    row.disabled = false
                }else {
                    row.disabled = true
                }
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
                }.cellUpdate({ (cell, row) in
                    if let tmpRowValue = row.value {
                        self.username = tmpRowValue
                    }
                })
            
            
            <<< PickerInputRow<String>(""){
                $0.title = "権限"
                $0.options = ["admin", "general"]
                $0.value = role
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
                $0.tag = "role"
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
                }.cellUpdate({ (cell, row) in
                    if let tmpRowValue = row.value {
                        self.role = tmpRowValue
                    }
                })
        
        
        tableView.height(self.view.frame.height / 4)
        tableView.top(to: self.view)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}