//
//  SearchShiftViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol SearchShiftViewInterface: class {
    var formValue: [String:Any?] { get }
    
    func initializeUI()
    func showReConfirmAlert()
    func navigateResultsView()
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
        
        self.navigationItem.title = "シフト検索"
        
        UIView.setAnimationsEnabled(false)
        presenter.setInitData()
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeForm() {
        let title_shift = "シフト"
        let title_category = "シフトカテゴリ"
        
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("検索条件")
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
            
        form +++ Section("使用する条件の切り替え")
            <<< SegmentedRow<String>("segments"){
                $0.options = [title_shift, title_category]
                $0.value = title_shift
            }
            
            <<< PickerInputRow<String>(""){
                $0.title = "シフト"
                $0.options = presenter.getShifts()
                $0.value = presenter.getShifts().first
                $0.tag = "shift"
                $0.hidden = Condition.function(["segments"], { form in
                    return (form.rowBy(tag: "segments") as? SegmentedRow<String>)?.value == title_shift ? false:true
                })
                $0.cell.detailTextLabel?.textColor = UIColor.black
            }

            <<< PickerInputRow<String>(""){
                $0.title = "シフトカテゴリ"
                $0.options = presenter.getCategories()
                $0.value = presenter.getCategories().first
                $0.tag = "category"
                $0.hidden = Condition.function(["segments"], { form in
                    return (form.rowBy(tag: "segments") as? SegmentedRow<String>)?.value == title_category ? false:true
                })
                $0.cell.detailTextLabel?.textColor = UIColor.black
        }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "検索"
                $0.baseCell.backgroundColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
            }
            .onCellSelection {  cell, row in
                self.presenter.search(isForced: false)
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
    
    func navigateResultsView() {
        let searchShiftVC = SearchShiftResultsViewController()
        searchShiftVC.setData(results: presenter.getSearchResults())
        let nav = UINavigationController()
        nav.viewControllers = [searchShiftVC]
        nav.modalTransitionStyle = .coverVertical
        self.present(nav, animated: true, completion: nil)
    }
    
    func showReConfirmAlert() {
        let forcedSearchButton = DefaultButton(title: "検索する", dismissOnTap: true) {
            self.presenter.search(isForced: true)
        }
        let cancelButton = DefaultButton(title: "キャンセル", dismissOnTap: true) {}
        let popup = PopupDialog(title: "再確認", message: "ファイルの検索条件が「指定なし」となっているため、検索に時間がかかる場合があります。\nそれでも検索を実行しますか？", transitionStyle: .zoomIn) {}
        popup.addButtons([forcedSearchButton, cancelButton])
        present(popup, animated: true, completion: nil)
    }
}
