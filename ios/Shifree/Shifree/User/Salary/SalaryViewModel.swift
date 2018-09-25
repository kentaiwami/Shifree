//
//  SalaryViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SalaryViewModelDelegate: class {
    func initializeUI()
    func reloadUI()
    func faildAPI(title: String, msg: String)
}

class SalaryViewModel {
    weak var delegate: SalaryViewModelDelegate?
    private let api = API()
    private(set) var salaryList: [Salary] = []
    private(set) var salaryMax: Double = 0.0
    
    func getSalary() {
        api.getSalary().done { (json) in
            self.salaryList = json["results"].arrayValue.map({ salaryJson in
                return Salary(pay: salaryJson["pay"].intValue, title: salaryJson["title"].stringValue)
            })
            
            self.setSalaryMax()
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func reCalcSalary() {
        api.reCalcSalary().done { (json) in
            self.salaryList = json["results"].arrayValue.map({ salaryJson in
                return Salary(pay: salaryJson["pay"].intValue, title: salaryJson["title"].stringValue)
            })
//            json["results"].arrayValue.forEach({ (salaryJson) in
//                self.salaryList.append(Salary(pay: salaryJson["pay"].intValue, title: salaryJson["title"].stringValue))
//            })
            
            self.setSalaryMax()
            self.delegate?.reloadUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    private func setSalaryMax() {
        var max = 0
        salaryList.forEach { (salary) in
            if max < salary.pay {
                max = salary.pay
            }
        }
        salaryMax = Double(max)
    }
}
