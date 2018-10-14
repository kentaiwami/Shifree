//
//  CalendarDetailViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol CalendarDetailViewInterface: class {
    var formValues: [String:Any?] { get }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func popViewController()
}

class CalendarDetailViewController: FormViewController, CalendarDetailViewInterface {
    var formValues: [String : Any?] = [:]
    fileprivate var presenter: CalendarDetailViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCompanyShiftNames()
    }
    
    init(title: String, tableViewShift: TableViewShift, memo: String, isFollowing: Bool, targetUserShift: TargetUserShift) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = CalendarDetailViewPresenter(view: self)
        presenter.setSelectedData(tableViewShift: tableViewShift, memo: memo, isFollowing: isFollowing, targetUserShift: targetUserShift)
        
        self.navigationItem.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCompanyShiftNames() {
        presenter.setCompanyShiftNames()
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        self.formValues = self.form.values()
        presenter.tapEditDoneButton()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        if presenter.isTargetInclude() && !presenter.isFollowing() {
            form +++ Section("メモ")
                <<< TextAreaRow(){
                    $0.title = ""
                    $0.tag = "memo"
                    $0.value = presenter.getMemo()
                    $0.placeholder = "このシフトに関するメモを残すことができます。"
            }
        }

        for userShift in presenter.getUsersShift() {
            form +++ Section("")
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
                        $0.cell.detailTextLabel?.textColor = UIColor.black
                    }else {
                        $0.disabled = true
                        $0.cell.detailTextLabel?.textColor = UIColor.gray
                    }
            }
        }
        UIView.setAnimationsEnabled(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CalendarDetailViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}
