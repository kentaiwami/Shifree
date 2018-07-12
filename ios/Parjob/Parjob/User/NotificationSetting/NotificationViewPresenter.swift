//
//  NotificationViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class NotificationViewPresenter {
    
    weak var view: NotificationViewInterface?
    let model: NotificationViewModel
    
    init(view: NotificationViewInterface) {
        self.view = view
        self.model = NotificationViewModel()
        model.delegate = self
    }
}

extension NotificationViewPresenter: NotificationViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
