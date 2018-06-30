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
    let calendarDetailModel: CalendarDetailModel
    
    init(view: CalendarDetailViewInterface) {
        self.view = view
        self.calendarDetailModel = CalendarDetailModel()
        calendarDetailModel.delegate = self
    }
    
    func setSelectedData(tableViewShift: TableViewShift, memo: String, targetUserShift: TargetUserShift) {
        calendarDetailModel.setSelectedData(tableViewShift: tableViewShift, memo: memo, targetUserShift: targetUserShift)
    }
    
    func isAdmin() -> Bool {
        return calendarDetailModel.isAdmin()
    }
    
    func isTargetInclude() -> Bool {
        return calendarDetailModel.isTargetInclude()
    }
    
    func getUsersShift() -> [UserShift] {
        return calendarDetailModel.tableViewShift.shifts
    }
    
    func getMemo() -> String {
        return calendarDetailModel.memo
    }
    
    func setCompanyShiftNames() {
        calendarDetailModel.getUserCompanyShiftNames()
    }
    
    func getCompanyShiftNames() -> [String] {
        return calendarDetailModel.companyShiftNames
    }
    
    func tapEditDoneButton() {
        calendarDetailModel.updateMemoAndShift(formValue: (view?.formValues)!)
    }
}

extension CalendarDetailViewPresenter: CalendarDetailModelDelegate {
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

