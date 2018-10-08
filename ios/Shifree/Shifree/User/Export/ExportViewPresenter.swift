//
//  ExportViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class ExportViewPresenter {
    
    weak var view: ExportViewInterface?
    let model: ExportViewModel
    
    init(view: ExportViewInterface) {
        self.view = view
        self.model = ExportViewModel()
        model.delegate = self
    }
    
    func setInitData() {
        model.setInitData()
    }
    
    func getTablesName() -> [String] {
        return model.getTablesName()
    }
    
    func getUsersName() -> [String] {
        return model.getUsersName()
    }
    
    func getInitValue() -> String {
        return model.getInitValue()
    }
    
    func export() {
        guard let formValue = view?.formValue else {return}
        model.export(formValue: formValue)
    }
}

extension ExportViewPresenter: ExportViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
