//
//  ShiftImportViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class ShiftImportViewPresenter {
    
    weak var view: ShiftImportViewInterface?
    let model: ShiftImportViewModel
    
    init(view: ShiftImportViewInterface) {
        self.view = view
        self.model = ShiftImportViewModel()
        model.delegate = self
    }
    
    func setThreshold() {
        model.setThreshold()
    }

    func importShift() {
        guard let formValues = view?.formValues else  { return }
        guard let filePath = view?.filePath else  { return }
        model.importShift(formValues: formValues, filePath: filePath)
    }
    
    func getThreshold() -> (sameLineTH: Float, usernameTH: Float, joinTH: Float, dayShiftTH: Float) {
        return (model.sameLineTH, model.usernameTH, model.joinTH, model.dayShiftTH)
    }
}

extension ShiftImportViewPresenter: ShiftImportViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func successImport() {
        view?.successImport()
    }
    
    func successImportButExistUnknown(unknown: [Unknown]) {
        view?.successImportButExistUnknown(unknown: unknown)
    }
    
    func faildImportBecauseUnRegisteredShift(unRegisteredShift: [String]) {
        view?.faildImportBecauseUnRegisteredShift(unRegisteredShift: unRegisteredShift)
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
