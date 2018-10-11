//
//  SearchShiftViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol SearchShiftViewInterface: class {
    var formValue: [String:Any?] { get }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}


class SearchShiftViewController: FormViewController, SearchShiftViewInterface {
    
    private var presenter: SearchShiftViewPresenter!
    var formValue: [String : Any?] {
        return form.values()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = SearchShiftViewPresenter(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "シフト検索"
        
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
        presenter.setInitData()
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("検索条件")
            <<< PickerInputRow<String>(""){
                $0.title = "シフトカテゴリ"
                $0.options = presenter.getCategories()
                $0.value = presenter.getCategories().first
                $0.tag = "category"
                $0.cell.detailTextLabel?.textColor = UIColor.black
        }
        
            <<< PickerInputRow<String>(""){
                $0.title = "シフト名"
                $0.options = presenter.getShifts()
                $0.value = presenter.getShifts().first
                $0.tag = "shift"
                $0.cell.detailTextLabel?.textColor = UIColor.black
        }
        
            <<< PickerInputRow<String>(""){
                $0.title = "ユーザ名"
                $0.options = presenter.getUsers()
                $0.value = presenter.getUsers().first
                $0.tag = "user"
                $0.cell.detailTextLabel?.textColor = UIColor.black
        }
        
            <<< PickerInputRow<String>(""){
                $0.title = "ファイル"
                $0.options = presenter.getTables()
                $0.value = presenter.getTables().first
                $0.tag = "table"
                $0.cell.detailTextLabel?.textColor = UIColor.black
        }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "検索"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                //TODO call API
            }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeNavigationItem() {
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Presenterから呼び出される関数
extension SearchShiftViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
