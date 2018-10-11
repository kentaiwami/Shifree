//
//  FollowSettingViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol FollowSettingViewInterface: class {
    var formValue: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
    func successUpdate()
}


class FollowSettingViewController: FormViewController, FollowSettingViewInterface {
    fileprivate var presenter: FollowSettingViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FollowSettingViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "フォローの設定"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        UIView.setAnimationsEnabled(true)
        
        presenter.setFollowUserAndComapnyUsers()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section()
            <<< SwitchRow("switchRowTag"){
                $0.title = "フォローを有効化"
                $0.value = presenter.isFollowing()
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "ユーザ名"
                $0.options = presenter.getFollowUserAndComapnyUsers().companyUsers
                $0.value = presenter.getFollowingUsername()
                $0.tag = "username"
                $0.cell.detailTextLabel?.textColor = UIColor.black
                $0.hidden = Condition.function(["switchRowTag"], { form in
                    return !((form.rowBy(tag: "switchRowTag") as? SwitchRow)?.value ?? false)
                })
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateFollow()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension FollowSettingViewController {
    func initializeUI() {
        initializeForm()
        initializeNavigationItem()
    }
    
    func successUpdate() {
        showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
