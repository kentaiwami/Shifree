//
//  NotificationViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol NotificationViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class NotificationViewModel {
    weak var delegate: NotificationViewModelDelegate?
    private let api = API()
}
