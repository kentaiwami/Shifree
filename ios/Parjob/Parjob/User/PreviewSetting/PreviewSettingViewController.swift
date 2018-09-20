//
//  PreviewSettingViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol PreviewSettingViewInterface: class {
    var formValue: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
    func successUpdate()
}


class PreviewSettingViewController: FormViewController, PreviewSettingViewInterface {
    fileprivate var presenter: PreviewSettingViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = PreviewSettingViewPresenter(view: self)
        presenter.setNotification()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "通知の設定"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
            form +++ Section()
                <<< SwitchRow(){
                    $0.title = "シフトの取り込み&削除"
                    $0.tag = "isShiftImport"
                    $0.value = presenter.getNotification().isShiftImport
                }
        
                <<< SwitchRow(){
                    $0.title = "コメント"
                    $0.tag = "isComment"
                    $0.value = presenter.getNotification().isComment
                }
        
                <<< SwitchRow(){
                    $0.title = "シフトの更新"
                    $0.tag = "isUpdateShift"
                    $0.value = presenter.getNotification().isUpdateShift
                }

        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateNotification()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension PreviewSettingViewController {
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
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
