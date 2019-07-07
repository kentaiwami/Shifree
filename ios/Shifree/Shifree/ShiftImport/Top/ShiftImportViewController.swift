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
    var formValues: [String:Any?] { get }
    
    func successImport()
    func successImportButExistUnknown(unknown: [Unknown])
    func faildImportBecauseUnRegisteredShift(unRegisteredShift: [String])
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}

class ShiftImportViewController: FormViewController, ShiftImportViewInterface {
    var formValues: [String : Any?] {
        return self.form.values()
    }
    
    private var presenter: ShiftImportViewPresenter!
    
    fileprivate let utility = Utility()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.setThreshold()
    }
    
    init(path: URL) {
        super.init(nibName: nil, bundle: nil)
        presenter = ShiftImportViewPresenter(view: self)
        presenter.setFilePath(path: path)
        
        self.navigationItem.title = "シフトの取り込み"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        form +++ Section("")
            <<< PhoneRow(){
                $0.title = "ユーザ数"
                $0.tag = "number"
                $0.add(rule: RuleRequired(msg: "必須項目です"))
                $0.validationOptions = .validatesOnChange
            }
            .onRowValidationChanged {cell, row in
                self.utility.showRowError(row: row)
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
                self.utility.showRowError(row: row)
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
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "upload"), style: .plain, target: self, action: #selector(tapImportButton))
        let close = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(tapCloseButton))
        self.navigationItem.setRightBarButton(check, animated: true)
        self.navigationItem.setLeftBarButton(close, animated: true)
    }
    
    @objc private func tapImportButton() {
        if utility.isValidateFormValue(form: form) {
            presenter.importShift()
        }else {
            utility.showStandardAlert(title: "エラー", msg: "入力されていない項目があります", vc: self)
        }
    }
    
    @objc private func tapCloseButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let topViewController = storyboard.instantiateInitialViewController()
        topViewController?.modalTransitionStyle = .crossDissolve
        self.present(topViewController!, animated: true, completion: nil)
    }
    
    private func navigateCalendar() {
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
            let unknownVC = UnknownViewController(unknown: unknown)
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
            let addShiftVC = AddShiftViewController(unRegisteredShift: unRegisteredShift)
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
        utility.showStandardAlert(title: title, msg: msg, vc: self)
    }
}
