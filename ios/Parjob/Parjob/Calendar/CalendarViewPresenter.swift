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
    
    init(view: CalendarViewInterface) {
        self.view = view
        self.calendarModel = CalendarModel()
        calendarModel.delegate = self
    }
    
    func login() {
        guard let start = view?.start else  { return }
        guard let end = view?.end else  { return }
        
        calendarModel.login(start: start, end: end)
    }
}

extension CalendarViewPresenter: CalendarModelDelegate {
    func initializeCalendar() {
        view?.initializeCalendar()
    }
    
    func faildLogin(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
