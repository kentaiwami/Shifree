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
    let calendarModel: CalendarModel
    
    var userShifts: [[String]] = []
    
    var shiftCategories:[String] {
        guard let currentDate = view?.currentDate else {return []}
        return calendarModel.getShiftCategories(currentDate: currentDate)
    }
    
    var eventNumber: Int {
        guard let currentDate = view?.targetDate else {return 0}
        return calendarModel.getEventNumber(date: currentDate)
    }
    
    var userColorScheme: String {
        guard let currentDate = view?.targetDate else {return ""}
        return calendarModel.getUserColorScheme(date: currentDate)
    }
    
    init(view: CalendarViewInterface) {
        self.view = view
        self.calendarModel = CalendarModel()
        calendarModel.delegate = self
    }
    
    func login() {
        calendarModel.login()
    }
    
    func getUserShift() {
        guard let start = view?.start else {return}
        guard let end = view?.end else {return}
        
        calendarModel.getAllUserShift(start: start, end: end)
    }
    
    func setUserShift() {
        guard let currentDate = view?.currentDate else {return}
        userShifts = calendarModel.setUserShifts(currentDate: currentDate)
    }
}

extension CalendarViewPresenter: CalendarModelDelegate {
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
