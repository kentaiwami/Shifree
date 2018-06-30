//
//  PopUpColorViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class PopUpColorViewPresenter {
    
    weak var view: PopUpColorViewInterface?
    let popUpColorModel: PopUpColorModel
    
    init(view: PopUpColorViewInterface) {
        self.view = view
        self.popUpColorModel = PopUpColorModel()
        popUpColorModel.delegate = self
    }
    
    func setShiftCategoryColor() {
        popUpColorModel.setShiftCategoryColor()
    }
    
    func getShiftCategoryColor() -> [ShiftCategoryColor] {
        return popUpColorModel.shiftCategoryColors
    }
    
}

extension PopUpColorViewPresenter: PopUpColorModelDelegate {
    func successGetShiftCategory() {
        view?.updateTableData()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
