//
//  ShiftImportViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess


protocol ShiftImportViewModelDelegate: class {
    func initializeUI()
    func successImport()
    func faildSignUp(title: String, msg: String)
}

class ShiftImportViewModel {
    weak var delegate: ShiftImportViewModelDelegate?
    private let api = API()
    private(set) var sameLineTH:Float = 0.0
    private(set) var usernameTH:Float = 0.0
    private(set) var joinTH:Float = 0.0
    private(set) var dayShiftTH:Float = 0.0
    
    func setThreshold() {
        api.getThreshold().done { (json) in
            self.sameLineTH = json["same_line_threshold"].floatValue
            self.usernameTH = json["username_threshold"].floatValue
            self.joinTH = json["join_threshold"].floatValue
            self.dayShiftTH = json["day_shift_threshold"].floatValue
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildSignUp(title: title, msg: tmp_err.domain)
        }
    }
    
    func importShift(formValues: [String:Any?], filePath: URL) {
        let start = GetFormatterDateString(format: "yyyy-MM-dd", date: formValues["start"] as! Date)
        let end = GetFormatterDateString(format: "yyyy-MM-dd", date: formValues["end"] as! Date)
        let number = formValues["number"] as! String
        let title = formValues["title"] as! String
        let sameLine = formValues["sameLine"] as! Float
        let username = formValues["username"] as! Float
        let join = formValues["join"] as! Float
        let dayShift = formValues["dayShift"] as! Float
        
        api.importShift(number: number, start: start, end: end, title: title, sameLine: String(sameLine), username: String(username), join: String(join), dayShift: String(dayShift), file: filePath).done { (json) in
            self.delegate?.successImport()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildSignUp(title: title, msg: tmp_err.domain)
        }
    }
}
