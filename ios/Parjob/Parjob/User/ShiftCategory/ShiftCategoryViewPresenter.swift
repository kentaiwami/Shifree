//
//  ShiftCategoryViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class ShiftCategoryViewPresenter {
    
    weak var view: ShiftCategoryViewInterface?
    let model: ShiftCategoryViewModel
    
    init(view: ShiftCategoryViewInterface) {
        self.view = view
        self.model = ShiftCategoryViewModel()
        model.delegate = self
    }
    
//    func updatePassword() {
//        guard let nowPassword = view?.nowPassword else {return}
//        guard let newPassword = view?.newPassword else {return}
//
//        model.updatePassword(now: nowPassword, new: newPassword)
//    }
}

extension ShiftCategoryViewPresenter: ShiftCategoryViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
