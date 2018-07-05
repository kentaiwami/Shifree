//
//  ShiftViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol ShiftViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class ShiftViewModel {
    weak var delegate: ShiftViewModelDelegate?
    private let api = API()
    private(set) var shiftDetail: [[ShiftDetail]] = []
    private(set) var shiftCategory: [ShiftCategory] = []
    
    func setShiftDetail() {
        api.getShift().done { (json) in
            json["results"].arrayValue.forEach({ (category) in
                self.shiftCategory.append(ShiftCategory(id: category["category_id"].intValue, name: category["category_name"].stringValue))
                
                var tmpShiftDetails: [ShiftDetail] = []
                category["shifts"].arrayValue.forEach({ (shift) in
                    tmpShiftDetails.append(ShiftDetail(id: shift["id"].intValue, name: shift["name"].stringValue, start: shift["start"].stringValue, end: shift["end"].stringValue))
                })
                
                self.shiftDetail.append(tmpShiftDetails)
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
//    func setInitShiftCategory(values: [String:Any?]) {
//        initFormValues = values
//    }
    
//    func setShiftCategory() {
//        api.getShiftCategory().done { (json) in
//            json["results"].arrayValue.forEach({ (shiftCategoryJson) in
//                var tmp = ShiftCategory()
//                tmp.id = shiftCategoryJson["category_id"].intValue
//                tmp.name = shiftCategoryJson["category_name"].stringValue
//                self.shiftCategory.append(tmp)
//            })
//            self.delegate?.initializeUI()
//        }
//        .catch { (err) in
//            let tmp_err = err as NSError
//            let title = "Error(" + String(tmp_err.code) + ")"
//            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//        }
//    }
    
//    func updateShiftCategory(values: [String:Any?]) {
//        let initFormValues = getNoNullableDict(nullableDict: self.initFormValues)
//        let formValues = getNoNullableDict(nullableDict: values)
//        var updates:[[String:Any]] = []
//        var deletes:[Int] = []
//        let adds: [String] = formValues.filter({$0.key.contains("_new")}).map({$0.value as! String})
//
//        initFormValues.keys.forEach { key in
//            if let tmpFormValue = formValues[key] as? String {
//                if tmpFormValue != initFormValues[key] as! String {
//                    updates.append(["id": getNumber(mixText: key), "name": tmpFormValue])
//                }
//            }else {
//                deletes.append(getNumber(mixText: key))
//            }
//        }
//
//        api.updateShiftCategory(adds: adds, updates: updates, deletes: deletes).done { (json) in
//            self.delegate?.success()
//        }
//        .catch { (err) in
//            let tmp_err = err as NSError
//            let title = "Error(" + String(tmp_err.code) + ")"
//            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//        }
//    }
}



// MARK: - 記述簡略化のため関数化
extension ShiftViewModel  {
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
