//
//  ExportViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol ExportViewInterface: class {
    var formValue: [String:Any?] { get }
    
    func initializeUI()
    func showAlert(title: String, msg: String)
}


class ExportViewController: FormViewController, ExportViewInterface {
    private var presenter: ExportViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ExportViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "エクスポート"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        UIView.setAnimationsEnabled(true)
        
        presenter.allowAuthorization()
        
        if presenter.isAuthorization() {
            presenter.setInitData()
        }else {
            let popup = PopupDialog(title: "確認", message: "エクスポート機能を利用するには、設定からカレンダーへのアクセスを許可する必要があります。", transitionStyle: .zoomIn) {
                self.navigationController?.popViewController(animated: true)
            }
            let after = DefaultButton(title: "あとで") {
                self.navigationController?.popViewController(animated: true)
            }
            let now = DefaultButton(title: "設定する") {
                if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
                }
            }
            popup.addButtons([now, after])
            present(popup, animated: true, completion: nil)
        }
    }
    
    private func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section()
            <<< PickerInputRow<String>(""){
                $0.title = "ファイル"
                $0.options = presenter.getTablesName()
                $0.value = presenter.getTablesName().first
                $0.tag = "table"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
        
            <<< PickerInputRow<String>(""){
                $0.title = "ユーザ"
                $0.options = presenter.getUsersName()
                $0.value = presenter.getInitValue()
                $0.tag = "user"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "カレンダー"
                $0.options = presenter.getCalendarsTitle()
                $0.value = presenter.getCalendarsTitle().first
                $0.tag = "calendar"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "書式"
                $0.options = presenter.getFormat()
                $0.value = presenter.getFormat().first
                $0.tag = "format"
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }
        
            <<< SwitchRow("allday") {
                $0.title = "終日"
                $0.value = true
            }
        
            <<< SwitchRow("overwrite") {
                $0.title = "上書き"
                $0.value = true
            }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "エクスポート"
                $0.disabled = Condition(booleanLiteral: !presenter.isAuthorization())
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                if self.presenter.isAuthorization() {
                    if isValidateFormValue(form: self.form) {
                        self.presenter.export()
                    }else {
                        showStandardAlert(title: "エラー", msg: "入力項目を再確認してください", vc: self)
                    }
                }
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension ExportViewController {
    func initializeUI() {
        initializeForm()
    }
    
    func showAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
