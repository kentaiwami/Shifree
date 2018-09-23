//
//  ShiftCategoryViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol ShiftCategoryViewInterface: class {
    var formValues: [String:Any?] { get }
    
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class ShiftCategoryViewController: FormViewController, ShiftCategoryViewInterface {
    
    fileprivate var presenter: ShiftCategoryViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ShiftCategoryViewPresenter(view: self)
        presenter.setShiftCategory()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "シフトカテゴリの設定"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        var count = 0
        
        form +++ MultivaluedSection(
            multivaluedOptions: [.Insert, .Delete],
            header: "",
            footer: "既にあるカテゴリを削除して同じ名前のカテゴリを登録しても、新規登録となるので注意してください。") {
                $0.addButtonProvider = { section in
                    section.showInsertIconInAddButton = true
                    return ButtonRow(){
                        $0.title = "カテゴリを追加"
                        }.cellUpdate({ (cell, row) in
                            cell.textLabel?.textAlignment = .left
                        })
                }

                $0.multivaluedRowToInsertAt = { _ in
                    return NameRow() {
                        $0.placeholder = "カテゴリ名"
                        $0.tag = String(count) + "_new"
                        count += 1
                    }
                }

                for shiftCategory in presenter.getShiftCategory() {
                    $0 <<< NameRow() {
                        $0.value = shiftCategory.name
                        $0.tag = String(shiftCategory.id) + "_exist"
                    }
                }
        }
        
        presenter.setInitShiftCategory(values: form.values())

        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateShiftCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - formでユーザが設定する値
extension ShiftCategoryViewController {
    var formValues: [String:Any?] {
        return self.form.values()
    }
}

// MARK: - Presenterから呼び出される関数
extension ShiftCategoryViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    func success() {
        showStandardAlert(title: "完了", msg: "情報を更新しました", vc: self) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}
