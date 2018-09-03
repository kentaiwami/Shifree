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
    
    /*
     シフト関連
    */
    func getAllUserShift() {
        model.getAllUserShift()
    }
    
    func setTableViewShift() {
        model.setTableViewShift()
    }
    
    func getTargetUserShift() -> TargetUserShift {
        return model.getTargetUserShift(date: nil)
    }
    
    
    /*
     Start, End関連
    */
    func setStartEndDate(start: Date, end: Date) {
        model.setStartEndDate(start: start, end: end)
    }
    
    func getStartEndDate() -> (start: Date, end: Date) {
        return model.getStartEndDate()
    }
    
    
    /*
     CurrentDate, CurrentPage関連
    */
    func initCurrentDate() {
        model.initCurrentDate()
    }
    
    func setCurrentPage(currentPage: Date) {
        model.setCurrentPage(currentPage: currentPage)
    }
    
    func setCurrentDate(date: Date) {
        model.setCurrentDate(currentDate: date)
    }
    
    func getCurrentAndPageDate() -> (currentPage: Date?, currentDate: Date) {
        return model.getCurrentAndPageDate()
    }
    
    
    
    /*
     カレンダー関連
    */
    func getUserColorSchemeForCalendar(date: Date) -> String {
        return model.getUserColorSchemeForCalendar(targetDate: date)
    }
    
    func getEventNumber(date: Date) -> Int {
        return model.getEventNumber(date: date)
    }
    
    func isTargetDateToday(targetDate: Date) -> Bool {
        return model.isTargetDateToday(targetDate: targetDate)
    }
    
    
    /*
     ScrollView関連
    */
    func getScrollPosition(target: Date) -> Int {
        return model.getScrollPosition(target: target)
    }
    
    func setCurrentScrollPage(page: Int) {
        model.setCurrentScrollPage(page: page)
    }
    
    func getNewSelectDateByScroll(newScrollPage: Int) -> Date {
        return model.getNewSelectDateByScroll(newScrollPage: newScrollPage)
    }
    
    
    /*
     TableView関連
    */
    func getTableViewShift(tag: Int) -> [TableViewShift] {
        return model.tableViewShifts[tag]
    }
    
    func getShiftCategories(tag: Int) -> [String] {
        return model.getShiftCategories(tag: tag)
    }
    
    func getUserColorSchemeForTable(tag: Int) -> String {
        return model.getUserColorSchemeForTable(tag: tag)
    }
    
    func getUserSection(tag: Int) -> Int {
        return model.getUserSection(tag: tag)
    }
    
    func getMemo() -> String {
        return model.getMemo()
    }
    
    
    
    //---------------------------------------------------
    
    
    
    
    
    
    
    
    
    
    func getShouldSelectDate(currentPage: Date, selectingDate: Date, isWeek: Bool) -> Date {
        return model.getShouldSelectDate(currentPage: currentPage, selectingDate: selectingDate, isWeek: isWeek)
    }
}


extension CalendarViewPresenter: CalendarViewModelDelegate {
    func updateTableViewData() {
        view?.updateView()
    }
    
    func initializeUI() {
        view?.initializeUI()
        model.getAllUserShift()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
