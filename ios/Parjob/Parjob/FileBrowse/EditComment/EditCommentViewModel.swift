//
//  EditCommentViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess
import PromiseKit
import SwiftyJSON


protocol EditCommentViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}


class EditCommentViewModel {
    weak var delegate: EditCommentViewModelDelegate?
    private let api = API()
    private(set) var comment: Comment!
    
    func setSelectedCommentData(comment: Comment) {
        self.comment = comment
    }
    
    func updateComment(formValue: [String:Any?]) {
        var text = ""
        if let tmpComment = formValue["Comment"] as? String {
            text = tmpComment
        }
        
        api.updateComment(text: text, id: comment.id).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
//    func isAdmin() -> Bool {
//        let keychain = Keychain()
//        let role = try! keychain.get("role")!
//
//        if role == "admin" {
//            return true
//        }else {
//            return false
//        }
//    }
    
//    func isTargetInclude() -> Bool {
//        for userShift in tableViewShift.shifts {
//            if userShift.id == targetUserShift.id {
//                return true
//            }
//        }
//
//        return false
//    }
    
//    func getUserCompanyShiftNames() {
//        api.getUserCompanyShiftNames().done { (json) in
//            json["results"].arrayValue.forEach { (shift) in
//                self.companyShiftNames.append(shift["name"].stringValue)
//            }
//            self.delegate?.initializeUI()
//        }
//        .catch { (err) in
//            let tmp_err = err as NSError
//            let title = "Error(" + String(tmp_err.code) + ")"
//            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//        }
//    }
    
//    func updateMemoAndShift(formValue: [String:Any?]) {
//        var differentUserShift: [[String:Any]] = []
//
//        for userShift in self.tableViewShift.shifts {
//            let key = String(userShift.id) + "_shift"
//
//            if let value = formValue[key] as? String {
//                if value != userShift.name {
//                    differentUserShift.append([
//                        "id": userShift.id,
//                        "name": value
//                    ])
//                }
//            }
//        }
//
//        if formValue["memo"] == nil && differentUserShift.count != 0 {
//            api.updateUserShift(shifts: differentUserShift).done { (json) in
//                self.delegate?.popViewController()
//            }
//            .catch { (err) in
//                let tmp_err = err as NSError
//                let title = "Error(" + String(tmp_err.code) + ")"
//                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//            }
//        }else if formValue["memo"] != nil && differentUserShift.count == 0 {
//            var memo = ""
//            if let tmpMemo = formValue["memo"] as? String {
//                memo = tmpMemo
//            }
//            api.updateMemo(userShiftID: targetUserShift.id, text: memo).done { (json) in
//                self.delegate?.popViewController()
//            }
//            .catch { (err) in
//                let tmp_err = err as NSError
//                let title = "Error(" + String(tmp_err.code) + ")"
//                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//            }
//        }else if formValue["memo"] != nil && differentUserShift.count != 0 {
//            var memo = ""
//            if let tmpMemo = formValue["memo"] as? String {
//                memo = tmpMemo
//            }
//
//            when(resolved: [api.updateMemo(userShiftID: targetUserShift.id, text: memo), api.updateUserShift(shifts: differentUserShift)]).done { (json) in
//                self.delegate?.popViewController()
//            }
//            .catch { (err) in
//                let tmp_err = err as NSError
//                let title = "Error(" + String(tmp_err.code) + ")"
//                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//            }
//        }else {
//            self.delegate?.popViewController()
//        }
//    }
}
