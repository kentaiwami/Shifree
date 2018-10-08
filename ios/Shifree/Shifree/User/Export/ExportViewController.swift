//
//  ExportViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol ExportViewInterface: class {}


class ExportViewController: FormViewController, ExportViewInterface {
    fileprivate var presenter: ExportViewPresenter!
    
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension ExportViewController {}
