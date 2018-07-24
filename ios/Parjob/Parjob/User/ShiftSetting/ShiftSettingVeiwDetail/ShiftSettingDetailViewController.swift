//
//  ShiftSettingDetailController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/03.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import TinyConstraints

class ShiftSettingDetailViewController: FormViewController {

    var name: String = ""
    var start: String = ""
    var end: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        form +++ Section("")
            <<< TextRow(){ row in
                row.title = "シフト名"
                row.value = name
                row.tag = "name"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
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
                        self.name = tmpRowValue
                    }
                })
            
            
            <<< PickerInputRow<String>(""){
                $0.title = "開始時間"
                $0.options = [""] + GetTime()
                $0.value = start
                $0.tag = "start"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
            .cellUpdate({ (cell, row) in
                if let tmpRowValue = row.value {
                    self.start = tmpRowValue
                }
            })
        
        
            <<< PickerInputRow<String>(""){
                $0.title = "終了時間"
                $0.options = [""] + GetTime()
                $0.value = end
                $0.tag = "end"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
            .cellUpdate({ (cell, row) in
                if let tmpRowValue = row.value {
                    self.start = tmpRowValue
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
