//
//  CalendarDetailViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess
import PromiseKit
import SwiftyJSON


protocol CalendarDetailViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
    func popViewController()
}


class CalendarDetailViewModel {
    weak var delegate: CalendarDetailViewModelDelegate?
    private let api = API()
    private(set) var tableViewShift: TableViewShift!
    private(set) var targetUserShift: TargetUserShift!
    private(set) var memo: String = ""
    private(set) var isFollowing: Bool = false
    private(set) var companyShiftNames: [String] = []
    
    func setSelectedData(tableViewShift: TableViewShift, memo: String, isFollowing: Bool, targetUserShift: TargetUserShift) {
        self.tableViewShift = tableViewShift
        self.memo = memo
        self.isFollowing = isFollowing
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
    
    func updateMemoAndShift(formValue: [String:Any?]) {
        var differentUserShift: [[String:Any]] = []
        
        for userShift in self.tableViewShift.shifts {
            let key = String(userShift.id) + "_shift"
            
            if let value = formValue[key] as? String {
                if value != userShift.name {
                    differentUserShift.append([
                        "id": userShift.id,
                        "name": value
                    ])
                }
            }
        }
        
        if formValue["memo"] == nil && differentUserShift.count != 0 {
            api.updateUserShift(shifts: differentUserShift).done { (json) in
                self.delegate?.popViewController()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }else if formValue["memo"] != nil && differentUserShift.count == 0 {
            var memo = ""
            if let tmpMemo = formValue["memo"] as? String {
                memo = tmpMemo
            }
            api.updateMemo(userShiftID: targetUserShift.id, text: memo).done { (json) in
                self.delegate?.popViewController()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }else if formValue["memo"] != nil && differentUserShift.count != 0 {
            var memo = ""
            if let tmpMemo = formValue["memo"] as? String {
                memo = tmpMemo
            }
            
            when(resolved: [api.updateMemo(userShiftID: targetUserShift.id, text: memo), api.updateUserShift(shifts: differentUserShift)]).done { (json) in
                self.delegate?.popViewController()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }else {
            self.delegate?.popViewController()
        }
    }
}
