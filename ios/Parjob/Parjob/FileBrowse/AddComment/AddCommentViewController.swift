//
//  AddCommentViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol AddCommentViewInterface: class {
    var formValues: [String:Any?] { get }
    var tableID: Int { get }
    
    func showErrorAlert(title: String, msg: String)
    func popupViewController()
}

class AddCommentViewController: FormViewController, AddCommentViewInterface {
    var formValues: [String : Any?] = [:]
    var tableID: Int = -1
    
    fileprivate var presenter: AddCommentViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "コメントの追加"
    }
    
    private func initializePresenter() {
        presenter = AddCommentViewPresenter(view: self)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if IsValidateFormValue(form: form) {
            self.formValues = self.form.values()
            presenter.tapEditDoneButton()
        }else {
            ShowStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self, completion: nil)
        }
    }
    
    @objc private func tapCloseButton() {
        popupViewController()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("")
            <<< TextAreaRow(){
                $0.title = "コメント"
                $0.tag = "Comment"
                $0.value = ""
                $0.placeholder = "タップしてコメントを入力…"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
        }
        .onRowValidationChanged {cell, row in
            let rowIndex = row.indexPath!.row
            while row.section!.count > rowIndex + 1 && row.section?[rowIndex  + 1] is LabelRow {
                row.section?.remove(at: rowIndex + 1)
            }
            if !row.isValid {
                for (index, err) in row.validationErrors.map({ $0.msg }).enumerated() {
                    let labelRow = LabelRow() {
                        $0.title = err
                        $0.cell.height = { 30 }
                        $0.cell.contentView.backgroundColor = .red
                        $0.cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textColor = .white
                        })
                    row.section?.insert(labelRow, at: row.indexPath!.row + index + 1)
                }
            }
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension AddCommentViewController {
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
    
    func popupViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}



// MARK: - インスタンス化される際に呼ばれる必要がある関数
extension AddCommentViewController {
    func setTableID(id: Int) {
        self.tableID = id
    }
}
