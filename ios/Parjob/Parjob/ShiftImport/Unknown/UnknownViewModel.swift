//
//  UnknownViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol UnknownViewModelDelegate: class {
    func successUpdate()
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class UnknownViewModel {
    weak var delegate: UnknownViewModelDelegate?
    private let api = API()
    private(set) var unknownList:[Unknown] = []
    private(set) var companyShiftNames: [String] = []
    
    func setUnknownList(unknown: [Unknown]) {
        unknownList = unknown
    }
    
    func setUserCompanyShiftNames() {
        api.getUserCompanyShiftNames().done { (json) in
            json["results"].arrayValue.forEach { (category) in
                category["shifts"].arrayValue.forEach({ (shift) in
                    self.companyShiftNames.append(shift["name"].stringValue)
                })
            }
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateUserShift(formValues:[String:Any?]) {
        // API: usercode, new_shift_name, dateが更新処理に必要
        var updates: [[String:Any]] = []
        
        let removedUnknownShift = formValues.filter { (key, value) -> Bool in
            if value as! String == "unknown" {
                return false
            }else {
                return true
            }
        }
        
        for (key, value) in removedUnknownShift {
            // [0]: userCode, [1]: date
            let userCodeDate = key.components(separatedBy: ",")
            updates.append(["code": userCodeDate[0], "name": value as! String, "date": userCodeDate[1]])
        }
        
        api.updateUnknownUserShift(updates: updates).done { (json) in
            self.delegate?.successUpdate()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
