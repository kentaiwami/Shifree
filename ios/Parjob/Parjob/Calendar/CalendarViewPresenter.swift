//
//  CalendarViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol CalendarViewPresentable :class{
    var shiftCategories: [String] { get }
    var eventNumber: Int { get }
    var userColorScheme: String { get }
}

class CalendarViewPresenter {
    
    weak var view: CalendarViewInterface?
    let model: CalendarViewModel
    
    init(view: CalendarViewInterface) {
        self.view = view
        self.model = CalendarViewModel()
        model.delegate = self
    }
    
    func login() {
        model.login()
    }
    
    func getShiftCategories(start: Date, tag: Int) -> [String] {
        return model.getShiftCategories(start: start, tag: tag)
    }
    
    var eventNumber: Int {
        guard let targetDate = view?.targetDate else {return 0}
        return model.getEventNumber(date: targetDate)
    }
    
    func getUserColorSchemeForTable(start: Date, tag: Int) -> String {
        return model.getUserColorSchemeForTable(start: start, tag: tag)
    }
    
    func getUserColorSchemeForCalendar() -> String {
        guard let targetDate = view?.targetDate else {return ""}
        return model.getUserColorSchemeForCalendar(targetDate: targetDate)
    }
    
    func getUserSection(start: Date, tag: Int) -> Int {
        return model.getUserSection(start: start, tag: tag)
    }
    
    func getUserShift(start: Date, end: Date) {
        model.getAllUserShift(start: start, end: end)
    }
    
    func getCurrentAndPageDate() -> (currentPage: Date?, currentDate: Date) {
        return model.getCurrentAndPageDate()
    }
    
    func setTableViewShift(start: Date, end: Date) {
        model.setTableViewShift(start: start, end: end)
    }
    
    func setCurrentPage(currentPage: Date) {
        model.setCurrentPage(currentPage: currentPage)
    }
    
    func getShouldSelectDate(currentPage: Date, selectingDate: Date, isWeek: Bool) -> Date {
        return model.getShouldSelectDate(currentPage: currentPage, selectingDate: selectingDate, isWeek: isWeek)
    }
    
    func getMemo() -> String {
        guard let currentDate = view?.currentDate else {return ""}
        return model.getMemo(date: currentDate)
    }
    
    func getTargetUserShift() -> TargetUserShift {
        guard let currentDate = view?.currentDate else {return TargetUserShift()}
        return model.getTargetUserShift(date: currentDate)
    }
    
    func getTableViewShift(tag: Int) -> [TableViewShift] {
        return model.tableViewShifts[tag]
    }
}


extension CalendarViewPresenter: CalendarViewModelDelegate {
    func updateTableViewData() {
        view?.updateTableViewData()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
