//
//  AddCommentViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol AddCommentViewInterface: class {
    var formValues: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func popupViewController()
}

class AddCommentViewController: FormViewController, AddCommentViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: AddCommentViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
    }
    
    init(tableID: Int) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = AddCommentViewPresenter(view: self)
        presenter.setTableID(id: tableID)
        
        self.navigationItem.title = "コメントの追加"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        if utility.isValidateFormValue(form: form) {
            presenter.tapEditDoneButton()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }
    
    @objc private func tapCloseButton() {
        popupViewController()
    }
    
    private func initializeForm() {
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
            self.utility.showRowError(row: row)
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
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popupViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
