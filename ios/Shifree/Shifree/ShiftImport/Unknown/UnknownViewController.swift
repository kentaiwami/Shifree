//
//  UnknownViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol UnknownViewInterface: class {
    var formValues:[String:Any?] { get }
    
    func initializeUI()
    func showAlert(title: String, msg: String)
}

class UnknownViewController: FormViewController, UnknownViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: UnknownViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.setUserCompanyShiftNames()
    }
    
    init(unknown: [Unknown]) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = UnknownViewPresenter(view: self)
        presenter.setUnknown(unknown: unknown)
        self.navigationItem.title = "Unknownの編集"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                picker.cell.detailTextLabel?.textColor = UIColor.black
                
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
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
