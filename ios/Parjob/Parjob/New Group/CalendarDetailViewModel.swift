//
//  CalendarDetailViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol CalendarDetailModelDelegate: class {
    func faildAPI(title: String, msg: String)
}

class CalendarDetailModel {
    weak var delegate: CalendarDetailModelDelegate?
    private let api = API()
    private(set) var tableViewShift: TableViewShift!
    
    func setSelectedData(tableViewShift: TableViewShift) {
        self.tableViewShift = tableViewShift
    }
}
