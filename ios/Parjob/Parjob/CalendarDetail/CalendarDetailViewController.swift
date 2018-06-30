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
    var formValues: [String:Any?] { get }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func popViewController()
}

class CalendarDetailViewController: FormViewController, CalendarDetailViewInterface {
    var indexPath: IndexPath = []
    var formValues: [String : Any?] = [:]
    fileprivate var presenter: CalendarDetailViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        setCompanyShiftNames()
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
    
    func setCompanyShiftNames() {
        presenter.setCompanyShiftNames()
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        self.formValues = self.form.values()
        presenter.tapEditDoneButton()
    }
    
    private func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        if presenter.isTargetInclude() {
            form +++ Section("Memo")
                <<< TextAreaRow(){
                    $0.title = "Memo"
                    $0.tag = "memo"
                    $0.value = presenter.getMemo()
                    $0.placeholder = "このシフトに関するメモを残すことができます。"
            }
        }

        for (i, userShift) in presenter.getUsersShift().enumerated() {
            var sectionName = "シフトの詳細"
            if i != 0 {
                sectionName = ""
            }
            
            form +++ Section(sectionName)
                <<< LabelRow() {
                    $0.title = "従業員"
                    $0.value = userShift.user
                    $0.tag = String(userShift.id) + "_name"
                }
                
                <<< PickerInputRow<String> {
                    $0.title = "シフト"
                    $0.value = userShift.name
                    $0.options = presenter.getCompanyShiftNames()
                    $0.tag = String(userShift.id) + "_shift"

                    if presenter.isAdmin() {
                        $0.disabled = false
                    }else {
                        $0.disabled = true
                    }
            }
        }
        UIView.setAnimationsEnabled(true)
    }
    
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    func setIndexPath(at: IndexPath) {
        self.indexPath = at
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
