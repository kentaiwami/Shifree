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
    var indexPath: IndexPath { get }
    
    func showErrorAlert(title: String, msg: String)
}

class CalendarDetailViewController: FormViewController, CalendarDetailViewInterface {

    var indexPath: IndexPath = []
    fileprivate var presenter: CalendarDetailViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        initializeUI()
    }
    
    private func initializePresenter() {
        let tabBarController = self.navigationController?.viewControllers[0] as! UITabBarController
        let calendarVC = tabBarController.viewControllers![0] as! CalendarViewController
        let tableViewShift = calendarVC.getTableViewShift()[indexPath.section]
        let memo = calendarVC.getMemo()
        let targetUserShift = calendarVC.getTargetUserShift()
        
        presenter = CalendarDetailViewPresenter(view: self)
        presenter.setSelectedData(tableViewShift: tableViewShift, memo: memo, targetUserShift: targetUserShift)
    }
    
    private func initializeUI() {
        if presenter.isTargetInclude {
            form +++ Section("Memo")
                <<< TextAreaRow(){
                    $0.title = "memo"
                    $0.tag = "memo"
                    $0.value = presenter.getMemo()
            }
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
