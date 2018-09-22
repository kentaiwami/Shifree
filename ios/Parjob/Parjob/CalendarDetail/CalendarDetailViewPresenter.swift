//
//  CalendarDetailViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class CalendarDetailViewPresenter {
    
    weak var view: CalendarDetailViewInterface?
    let model: CalendarDetailViewModel
    
    init(view: CalendarDetailViewInterface) {
        self.view = view
        self.model = CalendarDetailViewModel()
        model.delegate = self
    }
    
    func setSelectedData(tableViewShift: TableViewShift, memo: String, isFollowing: Bool, targetUserShift: TargetUserShift) {
        model.setSelectedData(tableViewShift: tableViewShift, memo: memo, isFollowing: isFollowing, targetUserShift: targetUserShift)
    }
    
    func isAdmin() -> Bool {
        return model.isAdmin()
    }
    
    func isTargetInclude() -> Bool {
        return model.isTargetInclude()
    }
    
    func isFollowing() -> Bool {
        return model.isFollowing
    }
    
    func getUsersShift() -> [UserShift] {
        return model.tableViewShift.shifts
    }
    
    func getMemo() -> String {
        return model.memo
    }
    
    func setCompanyShiftNames() {
        model.setUserCompanyShiftNames()
    }
    
    func getCompanyShiftNames() -> [String] {
        return model.companyShiftNames
    }
    
    func tapEditDoneButton() {
        model.updateMemoAndShift(formValue: (view?.formValues)!)
    }
}

extension CalendarDetailViewPresenter: CalendarDetailViewModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func popViewController() {
        view?.popViewController()
    }
}

