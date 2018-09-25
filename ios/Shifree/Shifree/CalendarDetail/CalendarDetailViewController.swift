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
    var indexPath: IndexPath { get }
    var formValues: [String:Any?] { get }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func popViewController()
}

class CalendarDetailViewController: FormViewController, CalendarDetailViewInterface {
    var formValues: [String : Any?] = [:]
    
    // CalendarViewControllerで選択されたデータ
    fileprivate(set) var indexPath: IndexPath = []
    fileprivate(set) var navigationTitle: String = ""
    fileprivate(set) var memo: String = ""
    fileprivate(set) var tableViewShifts: [TableViewShift] = []
    fileprivate(set) var targetUserShift: TargetUserShift!
    fileprivate(set) var isFollowing: Bool = false
    
    fileprivate var presenter: CalendarDetailViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        setCompanyShiftNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    private func initializePresenter() {
        presenter = CalendarDetailViewPresenter(view: self)
        presenter.setSelectedData(tableViewShift: tableViewShifts[indexPath.section], memo: memo, isFollowing: isFollowing, targetUserShift: targetUserShift)
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


// MARK: - インスタンス化される際に、呼ぶべき関数
extension CalendarDetailViewController {
    func setSelectedData(memo: String, isFollowing: Bool, title: String, indexPath: IndexPath, tableViewShifts: [TableViewShift], targetUserShift: TargetUserShift) {
        navigationTitle = title
        self.memo = memo
        self.isFollowing = isFollowing
        self.indexPath = indexPath
        self.tableViewShifts = tableViewShifts
        self.targetUserShift = targetUserShift
    }
}
