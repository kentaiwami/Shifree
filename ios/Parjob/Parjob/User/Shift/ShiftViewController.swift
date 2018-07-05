//
//  ShiftViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka

protocol ShiftViewInterface: class {
    var formValues: [String:Any?] { get }
    
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class ShiftViewController: FormViewController, ShiftViewInterface {
    
    fileprivate var presenter: ShiftViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = ShiftViewPresenter(view: self)
        presenter.setShiftDetail()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Shift Setting"
    }
    
    fileprivate func initializeForm() {
        UIView.setAnimationsEnabled(false)
        
        var count = 0
        
        for (shiftCategory, shiftDetails) in zip(presenter.getShiftCategory(), presenter.getShiftDetail()) {
            
            form +++
                MultivaluedSection(
                    multivaluedOptions: [.Insert, .Delete],
                    header: shiftCategory.name,
                    footer: "") {
                        $0.tag = "textfields"
                        $0.addButtonProvider = { section in
                            return ButtonRow(){
                                $0.title = "シフトを追加"
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textAlignment = .left
                            })
                        }
                        
                        let defaultTitle = "タップしてシフト情報を入力"
                        
                        $0.multivaluedRowToInsertAt = { index in
                            return ButtonRow() {
                                $0.title = defaultTitle
                                $0.value = defaultTitle
                                $0.tag = String(count) + "_new"
                                count += 1
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textAlignment = .left
                                if row.title! == defaultTitle {
                                    cell.textLabel?.textColor = .gray
                                }else {
                                    cell.textLabel?.textColor = .black
                                }
                            }).onCellSelection({ (cell, row) in
//                                let value = self.getUsernameRoleFromCellTitle(title: row.title!)
//                                self.TapUserCell(username: value.username, role: value.role, isNew: true, row: row, code: "")
                            })
                        }
                        
                        for shiftDetail in shiftDetails {
                            var format = "%@ %@ 〜 %@"
                            var arguments = [shiftDetail.name, shiftDetail.start, shiftDetail.end]
                            if shiftDetail.start == "" || shiftDetail.end == "" {
                                format = "%@"
                                arguments = [shiftDetail.name]
                            }
                            
                            print(self.getShiftnameStartEndFromCellTitle(title: String(format: format, arguments: arguments)))
                            
                            $0 <<< ButtonRow() {
                                $0.title = String(format: format, arguments: arguments)
                                $0.value = String(format: format, arguments: arguments)
                                $0.cell.textLabel?.numberOfLines = 0
                                $0.tag = String(shiftDetail.id) + "_exist"
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textAlignment = .left
                                cell.textLabel?.textColor = .black
                            }).onCellSelection({ (cell, row) in
//                                let value = self.getShiftnameStartEndFromCellTitle(title: row.title!)
//                                self.TapUserCell(username: value.username, role: value.role, isNew: false, row: row, code: user.code)
                            })
                        }
                }
        }
//        presenter.setInitShiftCategory(values: form.values())

        
        UIView.setAnimationsEnabled(true)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
//        presenter.updateShiftCategory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - formでユーザが設定する値
extension ShiftViewController {
    var formValues: [String:Any?] {
        return self.form.values()
    }
}

// MARK: - Presenterから呼び出される関数
extension ShiftViewController {
    func initializeUI() {
        initializeNavigationItem()
        initializeForm()
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
extension ShiftViewController {
    fileprivate func getShiftnameStartEndFromCellTitle(title: String) -> (name: String, start: String, end: String) {
        let shiftNameMatch = GetMatchStrings(targetString: title, pattern: ".*? ")
        let startMatch = GetMatchStrings(targetString: title, pattern: "[0-9]{2}:[0-9]{2} 〜")
        let endMatch = GetMatchStrings(targetString: title, pattern: "〜 [0-9]{2}:[0-9]{2}")
        
        if startMatch.count == 0 || endMatch.count == 0 {
            return (title, "", "")
        }
        
        if shiftNameMatch.count == 0 {
            return ("", "", "")
        }
        
        let shiftname = shiftNameMatch[0].substring(to: shiftNameMatch[0].index(before: shiftNameMatch[0].endIndex))
        let start = startMatch[0].replacingOccurrences(of: " |〜", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        let end = endMatch[0].replacingOccurrences(of: " |〜", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        return (shiftname, start, end)
    }
}
