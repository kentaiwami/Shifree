//
//  WageViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol WageViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

struct UserWage {
    var daytimeStart: String = ""
    var daytimeEnd: String = ""
    var nightStart: String = ""
    var nightEnd: String = ""
    var daytimeWage: Int = 0
    var nightWage: Int = 0
}

class WageViewModel {
    weak var delegate: WageViewModelDelegate?
    private let api = API()
    private(set) var userWage = UserWage()
    
    func setUserWage() {
        api.getUserWage().done { (json) in
            self.userWage.daytimeStart = json["results"]["daytime_start"].stringValue
            self.userWage.daytimeEnd = json["results"]["daytime_end"].stringValue
            self.userWage.nightStart = json["results"]["night_start"].stringValue
            self.userWage.nightEnd = json["results"]["night_end"].stringValue
            self.userWage.daytimeWage = json["results"]["daytime_wage"].intValue
            self.userWage.nightWage = json["results"]["night_wage"].intValue
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateUserWage(daytimeStart: String, daytimeEnd: String, nightStart: String, nightEnd: String, daytimeWage: Int, nightWage: Int) {
        api.updateUserWage(daytimeStart: daytimeStart, daytimeEnd: daytimeEnd, nightStart: nightStart, nightEnd: nightEnd, daytimeWage: daytimeWage, nightWage: nightWage).done({ (json) in
            self.delegate?.success()
        })
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
