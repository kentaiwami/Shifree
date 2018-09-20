//
//  PreviewSettingViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class PreviewSettingViewPresenter {
    
    weak var view: PreviewSettingViewInterface?
    let model: PreviewSettingViewModel
    
    init(view: PreviewSettingViewInterface) {
        self.view = view
        self.model = PreviewSettingViewModel()
        model.delegate = self
    }
    
    func setNotification() {
        model.setNotification()
    }
    
    func getNotification() -> (isShiftImport: Bool, isComment: Bool, isUpdateShift: Bool) {
        return (model.isShiftImport, model.isComment, model.isUpdateShift)
    }
    
    func updateNotification() {
        guard let formValue = view?.formValue else {return}
        model.updateNotification(formValue: formValue)
    }
}

extension PreviewSettingViewPresenter: PreviewSettingViewModelDelegate {
    func successUpdate() {
        view?.successUpdate()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
