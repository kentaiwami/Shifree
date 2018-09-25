//
//  ShiftCategoryViewPresenter.swift
//  Shifree
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
    
    func setShiftCategory() {
        model.setShiftCategory()
    }
    
    func getShiftCategory() -> [ShiftCategory] {
        return model.shiftCategory
    }
    
    func updateShiftCategory() {
        guard let values = view?.formValues else {return}
        model.updateShiftCategory(values: values)
    }
    
    func setInitShiftCategory(values: [String:Any?]) {
        model.setInitShiftCategory(values: values)
    }
}

extension ShiftCategoryViewPresenter: ShiftCategoryViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
