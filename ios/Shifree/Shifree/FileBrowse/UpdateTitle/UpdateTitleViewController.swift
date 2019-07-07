//
//  UpdateTitleViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol UpdateTitleViewInterface: class {
    var formValues: [String:Any?] { get }
    
    func showErrorAlert(title: String, msg: String)
    func popupViewController()
}

class UpdateTitleViewController: FormViewController, UpdateTitleViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: UpdateTitleViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeUI()
    }
    
    init(tableID: Int, tableTitle: String) {
        super.init(nibName: nil, bundle: nil)
        
        presenter = UpdateTitleViewPresenter(view: self)
        presenter.setData(id: tableID, title: tableTitle)
        
        self.navigationItem.title = "タイトルの変更"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            <<< TextRow(){
                $0.title = "タイトル"
                $0.tag = "Title"
                $0.value = presenter.getTableTitle()
                $0.placeholder = "タップしてタイトルを入力…"
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

extension UpdateTitleViewController {
    func showErrorAlert(title: String, msg: String) {
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
    
    func popupViewController() {
        self.dismiss(animated: true, completion: nil)
    }
}
