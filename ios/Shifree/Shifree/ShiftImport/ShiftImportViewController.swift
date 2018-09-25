//
//  ShiftImportViewController.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol ShiftImportViewInterface: class {
    var filePath: URL { get }
    var formValues: [String:Any?] { get }
    
    func successImport()
    func successImportButExistUnknown(unknown: [Unknown])
    func faildImportBecauseUnRegisteredShift(unRegisteredShift: [String])
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}

class ShiftImportViewController: FormViewController, ShiftImportViewInterface {
    var filePath: URL = URL(fileURLWithPath: "")
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: ShiftImportViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.setThreshold()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "シフトの取り込み"
        tableView.reloadData()
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("")
            <<< PhoneRow(){
                $0.title = "ユーザ数"
                $0.tag = "number"
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
            
            <<< DateRow(){
                $0.title = "開始日"
                $0.tag = "start"
                $0.value = Date()
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })

            <<< DateRow(){
                $0.title = "終了日"
                $0.tag = "end"
                $0.value = Date()
            }
            .cellSetup({ (cell, row) in
                cell.detailTextLabel?.textColor = UIColor.black
            })
            
            <<< TextRow(){ row in
                row.title = "タイトル"
                row.tag = "title"
                row.add(rule: RuleRequired(msg: "必須項目です"))
                row.validationOptions = .validatesOnChange
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
        
    form +++ Section(footer: "値が大きいほど、元々3行だったものが1行として扱われます。")
        <<< SliderRow() {
            $0.title = "行間の値"
            $0.value = presenter.getThreshold().sameLineTH
            $0.tag = "sameLine"
            $0.cell.slider.maximumValue = 10.0
            $0.cell.slider.minimumValue = 0.0
        }
        .cellSetup({ (cell, row) in
            cell.detailTextLabel?.textColor = UIColor.black
        })
        
    form +++ Section(footer: "値が大きいほど、より多くの文字列内にユーザ名が含まれているものとして扱います。")
        <<< SliderRow() {
            $0.title = "ユーザ名の距離"
            $0.value = presenter.getThreshold().usernameTH
            $0.tag = "username"
            $0.cell.slider.maximumValue = 10.0
            $0.cell.slider.minimumValue = 0.0
        }
        .cellSetup({ (cell, row) in
            cell.detailTextLabel?.textColor = UIColor.black
        })
        
    form +++ Section(footer: "値が大きいほど、より多くのセルを結合します。")
        <<< SliderRow() {
            $0.title = "セル結合"
            $0.value = presenter.getThreshold().joinTH
            $0.tag = "join"
            $0.cell.slider.maximumValue = 10.0
            $0.cell.slider.minimumValue = 0.0
        }
        .cellSetup({ (cell, row) in
            cell.detailTextLabel?.textColor = UIColor.black
        })
        
    form +++ Section(footer: "値が大きいほど、その日のシフトとして認識する距離が広がります。")
        <<< SliderRow() {
            $0.title = "シフト"
            $0.value = presenter.getThreshold().dayShiftTH
            $0.tag = "dayShift"
            $0.cell.slider.maximumValue = 10.0
            $0.cell.slider.minimumValue = 0.0
        }
        .cellSetup({ (cell, row) in
            cell.detailTextLabel?.textColor = UIColor.black
        })
        
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "upload"), style: .plain, target: self, action: #selector(tapImportButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapImportButton() {
        if isValidateFormValue(form: form) {
            presenter.importShift()
        }else {
            showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }
    
    @objc private func tapCloseButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topViewController = storyboard.instantiateInitialViewController()
        topViewController?.modalTransitionStyle = .crossDissolve
        self.present(topViewController!, animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = ShiftImportViewPresenter(view: self)
    }
    
    fileprivate func navigateCalendar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topVC = storyboard.instantiateInitialViewController()
        topVC?.modalTransitionStyle = .crossDissolve
        self.present(topVC!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数一覧
extension ShiftImportViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
    }
    
    func successImport() {
        let button = DefaultButton(title: "OK", dismissOnTap: true) {
            self.navigateCalendar()
        }
        let popup = PopupDialog(title: "取り込み完了", message: "シフトの取り込みをしました", transitionStyle: .zoomIn) {
            self.navigateCalendar()
        }
        
        popup.addButtons([button])
        present(popup, animated: true, completion: nil)
    }
    
    func successImportButExistUnknown(unknown: [Unknown]) {
        let nowEditButton = DefaultButton(title: "編集する", dismissOnTap: true) {
            let unknownVC = UnknownViewController()
            unknownVC.setUnknown(unknown: unknown)
            let nav = UINavigationController()
            nav.viewControllers = [unknownVC]
            self.present(nav, animated: true, completion: nil)
        }
        let afterButton = DefaultButton(title: "あとで", dismissOnTap: true) {
            self.navigateCalendar()
        }
        let popup = PopupDialog(title: "取り込み完了", message: "シフトの取り込みは完了しましたが、unknownとしてシフトを仮登録したユーザがいます。\n今すぐに編集しますか？", transitionStyle: .zoomIn) {
            self.navigateCalendar()
        }
        popup.addButtons([nowEditButton, afterButton])
        present(popup, animated: true, completion: nil)
    }
    
    func faildImportBecauseUnRegisteredShift(unRegisteredShift: [String]) {
        let nowEditButton = DefaultButton(title: "追加する", dismissOnTap: true) {
            let addShiftVC = AddShiftViewController()
            addShiftVC.setUnRegisteredShift(shift: unRegisteredShift)
            let nav = UINavigationController()
            nav.viewControllers = [addShiftVC]
            self.present(nav, animated: true, completion: nil)
        }
        let afterButton = DefaultButton(title: "あとで", dismissOnTap: true) {
            self.navigateCalendar()
        }
        let popup = PopupDialog(title: "取り込みエラー", message: "未登録のシフト名が含まれているため、シフトの取り込みに失敗しました。\n今すぐに新しいシフト名を追加しますか？\n(注)ただし、シフトカテゴリの追加が必要な場合は「ユーザ画面」から行ってください。", transitionStyle: .zoomIn) {
            self.navigateCalendar()
        }
        
        popup.addButtons([nowEditButton, afterButton])
        present(popup, animated: true, completion: nil)
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
    }
}


// MARK: - インスタンス化される際に呼ぶべき関数
extension ShiftImportViewController {
    func setFilePath(path: URL) {
        self.filePath = path
    }
}
