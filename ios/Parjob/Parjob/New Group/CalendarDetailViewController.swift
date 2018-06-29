//
//  CalendarDetailViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol CalendarDetailViewInterface: class {
    func showErrorAlert(title: String, msg: String)
}

class CalendarDetailViewController: FormViewController, CalendarDetailViewInterface {
    
    var indexPath: IndexPath = []
    fileprivate var presenter: CalendarDetailViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        
        form +++ Section("Memo")
            <<< TextAreaRow(){
                $0.title = "memo"
                $0.tag = "memo"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
        }
        
        form +++ Section("シフトの詳細")
            <<< LabelRow() {
                $0.title = "従業員名"
                $0.value = "岩見"
        }
        
            <<< PickerInputRow<String> {
                $0.title = "シフト名"
//                $0.tag = "aaa"
                $0.options = ["早カ", "遅", "遅カ", "公", "帯広応援"]
        }
        
        form +++ Section("")
            <<< LabelRow() {
                $0.title = "従業員名"
                $0.value = "岩見"
            }
            
            <<< PickerInputRow<String> {
                $0.title = "シフト名"
//                $0.tag = "aaa"
                $0.options = ["早カ", "遅", "遅カ", "公", "帯広応援"]
        }
        
        form +++ Section("")
            <<< LabelRow() {
                $0.title = "従業員名"
                $0.value = "岩見"
            }
            
            <<< PickerInputRow<String> {
                $0.title = "シフト名"
//                $0.tag = "aaa"
                $0.options = ["早カ", "遅", "遅カ", "公", "帯広応援"]
        }
        
    }
    
    private func initializePresenter() {
        presenter = CalendarDetailViewPresenter(view: self)
        presenter.setSelectedData(indexPath: indexPath)
    }
    
    func setIndexPath(at: IndexPath) {
        self.indexPath = at
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
