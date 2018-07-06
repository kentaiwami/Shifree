//
//  SalaryViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol SalaryViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class SalaryViewModel {
    weak var delegate: SalaryViewModelDelegate?
    private let api = API()
    private(set) var salaryList: [Salary] = []
    
    func getSalary() {
        api.getSalary().done { (json) in
            json["results"].arrayValue.forEach({ (salaryJson) in
                self.salaryList.append(Salary(pay: salaryJson["pay"].intValue, title: salaryJson["title"].stringValue))
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
