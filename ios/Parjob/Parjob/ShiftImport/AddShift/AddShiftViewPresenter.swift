//
//  AddShiftViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class AddShiftViewPresenter {
    
    weak var view: AddShiftViewInterface?
    let model: AddShiftViewModel
    
    init(view: AddShiftViewInterface) {
        self.view = view
        self.model = AddShiftViewModel()
        model.delegate = self
    }
    
    func setShiftCategory() {
        model.getShiftCategory()
    }
    
    func setUnRegisteredShift(unRegisteredShift:[String]) {
        model.setUnRegisteredShift(unRegisteredShift: unRegisteredShift)
    }
    
    func getShiftCategory() -> [ShiftCategory] {
        return model.shiftCategoryList
    }
    
    func getUnRegisteredShift() -> [String] {
        return model.unRegisteredShift
    }
    
    func AddShift() {
        guard let formValues = view?.formValues else {return}
        model.AddShift(formValues: formValues)
    }
}

extension AddShiftViewPresenter: AddShiftViewModelDelegate {
    func successAdd() {
        view?.showAlert(title: "更新完了", msg: "シフトを更新しました")
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showAlert(title: title, msg: msg)
    }
}
