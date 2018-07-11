//
//  ShiftViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog

protocol ShiftViewInterface: class {
    var formValues: [[String]] { get }
    
    func initializeUI()
    func success()
    func showErrorAlert(title: String, msg: String)
}


class ShiftViewController: FormViewController, ShiftViewInterface {
    
    fileprivate var presenter: ShiftViewPresenter!
    let defaultTitle = "タップしてシフト情報を入力"
    
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
                        
                        $0.multivaluedRowToInsertAt = { index in
                            return ButtonRow() {
                                $0.title = self.defaultTitle
                                $0.value = self.defaultTitle
                                $0.tag = String(count) + "_new"
                                count += 1
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textAlignment = .left
                                if row.title! == self.defaultTitle {
                                    cell.textLabel?.textColor = .gray
                                }else {
                                    cell.textLabel?.textColor = .black
                                }
                            }).onCellSelection({ (cell, row) in
                                let value = self.getShiftnameStartEndFromCellTitle(title: row.title!)
                                self.TapUserCell(id: -1, name: value.name, start: value.start, end: value.end, row: row)
                            })
                        }
                        
                        for shiftDetail in shiftDetails {
                            var format = "%@ %@ 〜 %@"
                            var arguments = [shiftDetail.name, shiftDetail.start, shiftDetail.end]
                            if shiftDetail.start == "" || shiftDetail.end == "" {
                                format = "%@"
                                arguments = [shiftDetail.name]
                            }
                            
                            $0 <<< ButtonRow() {
                                $0.title = String(format: format, arguments: arguments)
                                $0.value = String(format: "%@,%@,%@,%@", arguments: [String(shiftDetail.id), shiftDetail.name, shiftDetail.start, shiftDetail.end])
                                $0.cell.textLabel?.numberOfLines = 0
                                $0.tag = String(shiftDetail.id) + "_exist"
                            }.cellUpdate({ (cell, row) in
                                cell.textLabel?.textAlignment = .left
                                cell.textLabel?.textColor = .black
                            }).onCellSelection({ (cell, row) in
                                let value = self.getShiftnameStartEndFromCellTitle(title: row.title!)
                                self.TapUserCell(id: shiftDetail.id, name: value.name, start: value.start, end: value.end, row: row)
                            })
                        }
                }
        }
        
        tableView.backgroundView = GetEmptyView(msg: EmptyMessage.becauseNoShiftCategory.rawValue)
        
        if presenter.getShiftCategory().count == 0 {
            tableView.backgroundView?.isHidden = false
        }else {
            tableView.backgroundView?.isHidden = true
        }
        
        UIView.setAnimationsEnabled(true)
    }
    
    private func TapUserCell(id: Int, name: String, start: String, end: String, row: ButtonRow) {
        let vc = ShiftSettingDetailViewController()
        vc.name = name
        vc.start = start
        vc.end = end
        
        let popUp = PopupDialog(viewController: vc)
        let buttonOK = DefaultButton(title: "OK"){
            if IsValidateFormValue(form: vc.form) {
                let detaiVCValues = vc.form.values()
                var format = "%@ %@ 〜 %@"
                var arguments = [detaiVCValues["name"] as! String, detaiVCValues["start"] as! String, detaiVCValues["end"] as! String]
                if detaiVCValues["start"] as! String == "" || detaiVCValues["end"] as! String == "" {
                    format = "%@"
                    arguments = [detaiVCValues["name"] as! String]
                }
                
                row.title = String(format: format, arguments: arguments)
                row.value = String(format: "%@,%@,%@,%@", arguments: [String(id), detaiVCValues["name"] as! String, detaiVCValues["start"] as! String, detaiVCValues["end"] as! String])
                row.updateCell()
            }else {
                ShowStandardAlert(title: "Error", msg: "入力されていない項目があります。\n再度、やり直してください。", vc: self, completion: nil)
            }
        }
        
        let buttonCancel = CancelButton(title: "Cancel"){}
        popUp.addButton(buttonOK)
        popUp.addButton(buttonCancel)
        present(popUp, animated: true, completion: nil)
    }
    
    fileprivate func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "checkmark"), style: .plain, target: self, action: #selector(tapEditDoneButton))
        self.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func tapEditDoneButton() {
        presenter.updateShiftDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - formでユーザが設定する値
extension ShiftViewController {
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
        
        if title == defaultTitle {
            return ("", "", "")
        }
        
        if startMatch.count == 0 || endMatch.count == 0 {
            return (title, "", "")
        }
        
        if shiftNameMatch.count == 0 {
            return ("", "", "")
        }
        
        let shiftname = shiftNameMatch[0].replacingOccurrences(of: " ", with: "")
        let start = startMatch[0].replacingOccurrences(of: " |〜", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        let end = endMatch[0].replacingOccurrences(of: " |〜", with: "", options: NSString.CompareOptions.regularExpression, range: nil)
        return (shiftname, start, end)
    }
}
