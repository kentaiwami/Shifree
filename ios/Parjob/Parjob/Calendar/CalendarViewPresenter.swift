//
//  CalendarViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class CalendarViewPresenter {
    
    weak var view: CalendarViewInterface?
    let calendarModel: CalendarModel
    
    var shiftCategories: [String] = []
    var userShifts: [[String]] = []
    var userColorScheme: String = ""
    var eventNumber: Int = 0
    
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
        
        calendarModel.getUserShift(start: start, end: end)
    }
    
    func setUserShiftAndCategories() {
        guard let currentDate = view?.currentDate else {return}
        shiftCategories = calendarModel.getShiftCategories(currentDate: currentDate)
        userShifts = calendarModel.setUserShifts(currentDate: currentDate)
    }
    
    func setUserColorScheme(date: String) {
        userColorScheme = calendarModel.getUserColorScheme(date: date)
    }
    
    func setEventNumber(date: String) {
        eventNumber = calendarModel.getEventNumber(date: date)
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
