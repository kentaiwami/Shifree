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
    
    var shiftCategories:[String] {
        guard let currentDate = view?.currentDate else {return []}
        return model.getShiftCategories(currentDate: currentDate)
    }
    
    var eventNumber: Int {
        guard let targetDate = view?.targetDate else {return 0}
        return model.getEventNumber(date: targetDate)
    }
    
    var userColorScheme: String {
        guard let targetDate = view?.targetDate else {return ""}
        return model.getUserColorScheme(date: targetDate)
    }
    
    var userSection: Int {
        guard let targetDate = view?.targetDate else {return -1}
        return model.getUserSection(date: targetDate)
    }
    
    init(view: CalendarViewInterface) {
        self.view = view
        self.model = CalendarViewModel()
        model.delegate = self
    }
    
    func login() {
        model.login()
    }
    
    func getUserShift(start: String, end: String) {
        model.getAllUserShift(start: start, end: end)
    }
    
    func getCurrentAndPageDate() -> (currentPage: Date?, currentDate: Date) {
        return model.getCurrentAndPageDate()
    }
    
    func setTableViewShift() {
        guard let currentDate = view?.currentDate else {return}
        model.setTableViewShift(currentDate: currentDate)
    }
    
    func setCurrentPage(currentPage: Date) {
        model.setCurrentPage(currentPage: currentPage)
    }
    
    func getShouldSelectDate(currentPage: Date, selectingDate: Date, isWeek: Bool) -> Date {
        return model.getShouldSelectDate(currentPage: currentPage, selectingDate: selectingDate, isWeek: isWeek)
    }
    
    
    /// TableViewで描画、CalendarDetailViewからのアクセスで使用
    ///
    /// - Returns: TableViewで描画する選択状態にある日のシフト情報
    func getTableViewShift() -> [TableViewShift] {
        return model.tableViewShifts
    }
}


// MARK: - CalendarDetailViewからアクセスして、変数を取り出すための関数一覧
extension CalendarViewPresenter {
    func getMemo() -> String {
        guard let currentDate = view?.currentDate else {return ""}
        return model.getMemo(date: currentDate)
    }
    
    func getTargetUserShift() -> TargetUserShift {
        guard let currentDate = view?.currentDate else {return TargetUserShift()}
        return model.getTargetUserShift(date: currentDate)
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
