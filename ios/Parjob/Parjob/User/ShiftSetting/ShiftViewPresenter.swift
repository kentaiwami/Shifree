//
//  ShiftViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class ShiftViewPresenter {
    
    weak var view: ShiftViewInterface?
    let model: ShiftViewModel
    
    init(view: ShiftViewInterface) {
        self.view = view
        self.model = ShiftViewModel()
        model.delegate = self
    }
        
    func setShiftDetail() {
        model.setShiftDetail()
    }
    
    func getShiftCategory() -> [ShiftCategory] {
        return model.shiftCategory
    }
    
    func getShiftDetail() -> [[ShiftDetail]] {
        return model.shiftDetail
    }
    
    func updateShiftDetail() {
        guard let formValues = view?.formValues else {return}
        model.updateShiftDetail(formValues: formValues)
    }
}

extension ShiftViewPresenter: ShiftViewModelDelegate {
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
