//
//  FileBrowseDetailViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol FileBrowseDetailViewInterface: class {
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class FileBrowseDetailViewController: FormViewController, FileBrowseDetailViewInterface {
    
    fileprivate var presenter: FileBrowseDetailViewPresenter!
    var navigationTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = FileBrowseDetailViewPresenter(view: self)
//        presenter.setShiftDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = navigationTitle
    }
    
    func setTitle(title: String) {
        self.navigationTitle = title
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

// MARK: - Presenterから呼び出される関数
extension FileBrowseDetailViewController {
    func initializeUI() {
        
    }
    
    func success() {
        ShowStandardAlert(title: "Success", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - 可読性のために関数化
extension FileBrowseDetailViewController {
}
