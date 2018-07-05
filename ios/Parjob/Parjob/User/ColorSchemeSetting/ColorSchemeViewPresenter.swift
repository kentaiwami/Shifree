//
//  ColorSchemViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class ColorSchemViewPresenter {
    
    weak var view: ColorSchemViewInterface?
    let model: ColorSchemViewModel
    
    init(view: ColorSchemViewInterface) {
        self.view = view
        self.model = ColorSchemViewModel()
        model.delegate = self
    }
    
    func setShiftCategoryColor() {
        model.setShiftCategoryColor()
    }
    
    func getShiftCategoryColor() -> [ShiftCategoryColor] {
        return model.shiftCategoryColors
    }
    
}

extension ColorSchemViewPresenter: ColorSchemViewModelDelegate {
    func successGetShiftCategory() {
        view?.updateTableData()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
