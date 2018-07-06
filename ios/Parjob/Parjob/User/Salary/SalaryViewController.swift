//
//  SalaryViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol SalaryViewInterface: class {
    func showErrorAlert(title: String, msg: String)
    func initializeUI()
}


class SalaryViewController: FormViewController, SalaryViewInterface {
    fileprivate var presenter: SalaryViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SalaryViewPresenter(view: self)
        presenter.setSalary()
    }
    
    fileprivate func initializeGraph() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Salary View"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension SalaryViewController {
    func initializeUI() {
        initializeGraph()
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}
