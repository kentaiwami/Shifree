//
//  UpdateTitleViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class UpdateTitleViewPresenter {
    
    weak var view: UpdateTitleViewInterface?
    let model: UpdateTitleViewModel
    
    init(view: UpdateTitleViewInterface) {
        self.view = view
        self.model = UpdateTitleViewModel()
        model.delegate = self
    }
    
    func setData(id: Int, title: String) {
        model.setData(id: id, title: title)
    }
    
    func getTableTitle() -> String {
        return model.tableTitle
    }
    
    func tapEditDoneButton() {
        guard let formValue = view?.formValues else { return }
        model.updateTitle(formValue: formValue)
    }
}

extension UpdateTitleViewPresenter: UpdateTitleViewModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
    
    func success() {
        view?.popupViewController()
    }
}

