//
//  CalendarDetailViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol CalendarDetailModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

struct Shift {
    var id: Int = 0
    var name: String = ""
}


class CalendarDetailModel {
    weak var delegate: CalendarDetailModelDelegate?
    private let api = API()
    private(set) var tableViewShift: TableViewShift!
    private(set) var targetUserShift: TargetUserShift!
    private(set) var memo: String = ""
    private(set) var companyShiftNames: [String] = []
    
    func setSelectedData(tableViewShift: TableViewShift, memo: String, targetUserShift: TargetUserShift) {
        self.tableViewShift = tableViewShift
        self.memo = memo
        self.targetUserShift = targetUserShift
    }
    
    func isAdmin() -> Bool {
        let keychain = Keychain()
        let role = try! keychain.get("role")!
        
        if role == "admin" {
            return true
        }else {
            return false
        }
    }
    
    func isTargetInclude() -> Bool {
        for userShift in tableViewShift.shifts {
            if userShift.id == targetUserShift.id {
                return true
            }
        }
        
        return false
    }
    
    func getUserCompanyShiftNames() {
        api.getUserCompanyShiftNames().done { (json) in
            json["results"].arrayValue.forEach { (shift) in
                self.companyShiftNames.append(shift["name"].stringValue)
            }
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
