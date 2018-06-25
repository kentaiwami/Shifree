//
//  CalendarViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess


protocol CalendarModelDelegate: class {
    func initializeCalendar()
    func faildLogin(title: String, msg: String)
}

class CalendarModel {
    weak var delegate: CalendarModelDelegate?
    private let api = API()
    
    func login(start: String, end: String) {
        api.login().then({ (json) in
            self.api.getUserShift(start: start, end: end)
        }).done({ (json) in
            self.delegate?.initializeCalendar()
        })
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildLogin(title: title, msg: tmp_err.domain)
        }
    }
}
