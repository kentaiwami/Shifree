//
//  UnknownViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol UnknownViewInterface: class {
    var unknown:[Unknown] { get }
    var formValues:[String:Any?] { get }
    
    func initializeUI()
    func showAlert(title: String, msg: String)
}

class UnknownViewController: FormViewController, UnknownViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    var unknown:[Unknown] = []
    
    private var presenter: UnknownViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        presenter.setUnknown(unknown: unknown)
        presenter.setUserCompanyShiftNames()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Edit Unknown Shift"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        for user in presenter.getUnknown() {
            let sectionName = user.username + "(" + String(user.order) + "番)"
            let section = Section(sectionName)
            
            for date in user.date {
                let tag = user.userCode + "," + date
                let picker = PickerInputRow<String>()
                picker.title = date
                picker.options = presenter.getUserCompanyShiftNames()
                picker.value = "unknown"
                picker.tag = tag
                
                section.append(picker)
            }
            form.append(section)
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateUserShift()
    }
    
    @objc private func tapCloseButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topVC = storyboard.instantiateInitialViewController()
        topVC?.modalTransitionStyle = .crossDissolve
        self.present(topVC!, animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = UnknownViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数一覧
extension UnknownViewController {
    
    func initializeUI() {
        initializeForm()
        initializeNavigationItem()
    }
    
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - インスタンス化される際に、呼ばれるべき関数
extension UnknownViewController {
    func setUnknown(unknown: [Unknown]) {
        self.unknown = unknown
    }
}