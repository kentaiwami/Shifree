//
//  ShiftCategoryViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ShiftCategoryViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class ShiftCategoryViewModel {
    weak var delegate: ShiftCategoryViewModelDelegate?
    private let api = API()
    private(set) var shiftCategory: [ShiftCategory] = []
    private(set) var initFormValues: [String:Any?] = [:]
    
    func setInitShiftCategory(values: [String:Any?]) {
        initFormValues = values
    }
    
    func setShiftCategory() {        
        api.getShiftCategory().done { (json) in
            self.shiftCategory = json["results"].arrayValue.map({shiftCategoryJson in
                var tmp = ShiftCategory()
                tmp.id = shiftCategoryJson["category_id"].intValue
                tmp.name = shiftCategoryJson["category_name"].stringValue
                return tmp
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateShiftCategory(values: [String:Any?]) {
        let initFormValues = getNoNullableDict(nullableDict: self.initFormValues)
        let formValues = getNoNullableDict(nullableDict: values)
        var updates:[[String:Any]] = []
        var deletes:[Int] = []
        let adds: [String] = formValues.filter({$0.key.contains("_new")}).map({$0.value as! String})
        
        initFormValues.keys.forEach { key in
            if let tmpFormValue = formValues[key] as? String {
                if tmpFormValue != initFormValues[key] as! String {
                    updates.append(["id": getNumber(mixText: key), "name": tmpFormValue])
                }
            }else {
                deletes.append(getNumber(mixText: key))
            }
        }
        
        api.updateShiftCategory(adds: adds, updates: updates, deletes: deletes).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}



// MARK: - 記述簡略化のため関数化
extension ShiftCategoryViewModel  {
    func getNoNullableDict(nullableDict: [String:Any?]) -> [String:Any] {
        let dict = nullableDict.reduce([String : Any]()) { (dict, e) in
            guard let value = e.1 else { return dict }
            var dict = dict
            dict[e.0] = value
            return dict
        }
        return dict
    }
    
    func getNumber(mixText: String) -> Int {
        let splitNumbers = (mixText.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        
        return Int(number)!
    }
}
