//
//  NotificationViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol NotificationViewModelDelegate: class {
    func initializeUI()
    func successUpdate()
    func faildAPI(title: String, msg: String)
}

class NotificationViewModel {
    weak var delegate: NotificationViewModelDelegate?
    private let api = API()
    private(set) var isShiftImport = false
    private(set) var isComment = false
    private(set) var isUpdateShift = false
    
    func setNotification() {
        api.getNotification().done { (json) in
            self.isShiftImport = json["is_shift_import"].boolValue
            self.isComment = json["is_comment"].boolValue
            self.isUpdateShift = json["is_update_shift"].boolValue
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateNotification(formValue: [String:Any?]) {
        let isShiftImport = formValue["isShiftImport"] as! Bool
        let isComment = formValue["isComment"] as! Bool
        let isUpdateShift = formValue["isUpdateShift"] as! Bool
        
        api.updateNotification(isShiftImport: isShiftImport, isComment: isComment, isUpdateShift: isUpdateShift).done { (json) in
            self.delegate?.successUpdate()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
