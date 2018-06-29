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
    
    func setSelectedData(indexPath: IndexPath) {
        calendarDetailModel.setSelectedData(indexPath: indexPath)
    }
}

extension CalendarDetailViewPresenter: CalendarDetailModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}

