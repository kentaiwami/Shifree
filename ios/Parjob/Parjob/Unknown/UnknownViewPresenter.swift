//
//  UnknownViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class UnknownViewPresenter {
    
    weak var view: UnknownViewInterface?
    let model: UnknownViewModel
    
    init(view: UnknownViewInterface) {
        self.view = view
        self.model = UnknownViewModel()
        model.delegate = self
    }
    
    func setUnknown(unknown:[Unknown]) {
        model.setUnknownList(unknown: unknown)
    }
    
    func getUnknown() -> [Unknown] {
        return model.unknownList
    }
    
    func setUserCompanyShiftNames() {
        model.setUserCompanyShiftNames()
    }
    
    func getUserCompanyShiftNames() -> [String] {
        return model.companyShiftNames
    }
    
    func updateUserShift() {
        guard let formValues = view?.formValues else {return}
        model.updateUserShift(formValues: formValues)
    }
}

extension UnknownViewPresenter: UnknownViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
