//
//  PopUpColorViewPresenter.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class PopUpColorViewPresenter {
    
    weak var view: PopUpColorViewInterface?
    let model: PopUpColorViewModel
    
    init(view: PopUpColorViewInterface) {
        self.view = view
        self.model = PopUpColorViewModel()
        model.delegate = self
    }
    
    func setShiftCategoryColor() {
        model.setShiftCategoryColor()
    }
    
    func getShiftCategoryColor() -> [ShiftCategoryColor] {
        return model.shiftCategoryColors
    }
    
}

extension PopUpColorViewPresenter: PopUpColorViewModelDelegate {
    func successGetShiftCategory() {
        view?.updateTableData()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
