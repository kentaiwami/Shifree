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
    
    // ScrollView, Calendarで使用
    func isSameDate(targetDate1: Date, targetDate2: Date) -> Bool {
        return model.isSameDate(targetDate1: targetDate1, targetDate2: targetDate2)
    }
    
    func resetValues() {
        model.resetValues()
    }
}


// MARK: - シフト関連
extension CalendarViewPresenter {
    func getAllUserShift() {
        model.getAllUserShift()
    }
    
    func setTableViewShift() {
        model.setTableViewShift()
    }
    
    func getTargetUserShift() -> TargetUserShift {
        return model.getTargetUserShift(date: nil)
    }
}


// MARK: - Start, End関連
extension CalendarViewPresenter {
    func setStartEndDate(start: Date, end: Date) {
        model.setStartEndDate(start: start, end: end)
    }
    
    func getStartEndDate() -> (start: Date, end: Date) {
        return model.getStartEndDate()
    }
}


// MARK: - CurrentDate, CurrentPage関連
extension CalendarViewPresenter {
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
}



// MARK: - TableCount
extension CalendarViewPresenter {
    func setTableCount(isWeek: Bool) {
        model.setTableCount(isWeek: isWeek)
    }
    
    func getTableCount() -> Int {
        return model.getTableCount()
    }
}



// MARK: - IsTapedTabBar
extension CalendarViewPresenter {
    func setIsTapedTabBar(value: Bool) {
        model.setIsTapedTabBar(value: value)
    }
    
    func getIsTapedTabBar() -> Bool {
        return model.getIsTapedTabBar()
    }
}



// MARK: - IsFirstTime
extension CalendarViewPresenter {
    func setIsFirstTime(value: Bool) {
        model.setIsFirstTime(value: value)
    }
    
    func getIsFirstTime() -> Bool {
        return model.getIsFirstTime()
    }
}



// MARK: - isSwipe
extension CalendarViewPresenter {
    func setIsSwipe(value: Bool) {
        model.setIsSwipe(value: value)
    }
    
    func getIsSwipe() -> Bool {
        return model.getIsSwipe()
    }
}



// MARK: - isReceiveNotificationSetCurrentPage
extension CalendarViewPresenter {
    func setIsReceiveNotificationSetCurrentPage(value: Bool) {
        model.setIsReceiveNotificationSetCurrentPage(value: value)
    }
    
    func getIsReceiveNotificationSetCurrentPage() -> Bool {
        return model.getIsReceiveNotificationSetCurrentPage()
    }
}



// MARK: - prevViewController（タブバーがタップされた際の画面の型を保存。）
extension CalendarViewPresenter {
    func setPrevViewController(value: Any.Type) {
        model.setPrevViewController(value: value)
    }
    
    func getPrevViewController() -> Any.Type {
        return model.getPrevViewController()
    }
}



// MARK: - カレンダー関連
extension CalendarViewPresenter {
    func getUserColorSchemeForCalendar(date: Date) -> String {
        return model.getUserColorSchemeForCalendar(targetDate: date)
    }
    
    func getEventNumber(date: Date) -> Int {
        return model.getEventNumber(date: date)
    }
    
    func getShouldSelectDate(currentPage: Date, isWeek: Bool) -> Date {
        return model.getShouldSelectDate(currentPageDate: currentPage, isWeek: isWeek)
    }
}


// MARK: - ScrollView関連
extension CalendarViewPresenter {
    func getScrollViewPosition(target: Date) -> Int {
        return model.getScrollViewPosition(target: target)
    }
    
    func setCurrentScrollPage(page: Int) {
        model.setCurrentScrollPage(page: page)
    }
    
    func getNewSelectDateByScroll(newScrollPage: Int) -> Date {
        return model.getNewSelectDateByScroll(newScrollPage: newScrollPage)
    }
}


// MARK: - TableView関連
extension CalendarViewPresenter {
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
    
    func getTableViewScrollPosition(date: Date) -> (scrollPosition: IndexPath, tableViewPosition: Int) {
        return model.getTableViewScrollPosition(date: date)
    }
}



// MARK: - Notification関連
extension CalendarViewPresenter {
    func getSunDayAndUpdated(object: Any?) -> (sunday: Date, updated: Date) {
        return model.getSunDayAndUpdated(object: object)
    }
}



// MARK: - CalendarViewModelDelegate（Modelから呼び出し）
extension CalendarViewPresenter: CalendarViewModelDelegate {
    func updateView() {
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
