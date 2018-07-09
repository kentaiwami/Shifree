//
//  SalaryViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class SalaryViewPresenter {
    
    weak var view: SalaryViewInterface?
    let model: SalaryViewModel
    
    init(view: SalaryViewInterface) {
        self.view = view
        self.model = SalaryViewModel()
        model.delegate = self
    }
    
    func setSalary() {
        model.getSalary()
    }
    
    func getSalary() -> [Salary] {
        return model.salaryList
    }
    
    func reloadSalary() {
        model.reCalcSalary()
    }
    
    func getSalaryMax() -> Double {
        return model.salaryMax
    }
}

extension SalaryViewPresenter: SalaryViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func reloadUI() {
        view?.reloadUI()
    }

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
