//
//  AddShiftViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol AddShiftViewInterface: class {
    var unRegisteredShift:[String] { get }
    var formValues:[[String]] { get }
    
    func initializeUI()
    func showAlert(title: String, msg: String)
}

class AddShiftViewController: FormViewController, AddShiftViewInterface {
    var formValues: [[String]] {
        var results: [[String]] = []
        
        for section in self.form.allSections {
            var tmpRowValues: [String] = []
            for row in section {
                if let tmp = row.baseValue as? String {
                    tmpRowValues.append(tmp)
                }
            }
            results.append(tmpRowValues)
        }
        
        return results
    }
    
    var unRegisteredShift:[String] = []
    
    private var presenter: AddShiftViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        presenter.setShiftCategory()
        presenter.setUnRegisteredShift(unRegisteredShift: unRegisteredShift)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "シフトの追加"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form.append(Section(header: "シフトカテゴリを空にしたシフトは登録されません。", footer: ""))
        
        for (i, shiftName) in presenter.getUnRegisteredShift().enumerated() {
            let section = Section()
            
            let labelRow = LabelRow()
            labelRow.title = "シフト名"
            labelRow.value = shiftName
            labelRow.tag = "name," + String(i)
            
            let shiftCategoryRow = PickerInputRow<String>()
            shiftCategoryRow.title = "シフトカテゴリ"
            shiftCategoryRow.options = [""] + presenter.getShiftCategory().map({$0.name})
            shiftCategoryRow.value = ""
            shiftCategoryRow.tag = "category," + String(i)
            
            let startRow = PickerInputRow<String>()
            startRow.title = "開始時間"
            startRow.options = [""] + GetTime()
            startRow.value = ""
            startRow.tag = "start," + String(i)
            
            let endRow = PickerInputRow<String>()
            endRow.title = "終了時間"
            endRow.options = [""] + GetTime()
            endRow.value = ""
            endRow.tag = "end," + String(i)

            section.append(labelRow)
            section.append(shiftCategoryRow)
            section.append(startRow)
            section.append(endRow)
            form.append(section)
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.AddShift()
    }
    
    @objc private func tapCloseButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = AddShiftViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数一覧
extension AddShiftViewController {
    
    func initializeUI() {
        initializeForm()
        initializeNavigationItem()
    }
    
    func showAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - インスタンス化される際に、呼ばれるべき関数
extension AddShiftViewController {
    func setUnRegisteredShift(shift: [String]) {
        self.unRegisteredShift = shift
    }
}
