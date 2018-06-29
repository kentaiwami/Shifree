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
    func faildAPI(title: String, msg: String)
}

class CalendarDetailModel {
    weak var delegate: CalendarDetailModelDelegate?
    private let api = API()
    private(set) var tableViewShift: TableViewShift!
    private(set) var targetUserShift: TargetUserShift!
    private(set) var memo: String = ""
    
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
}
