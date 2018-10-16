//
//  AnalyticsViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class AnalyticsViewPresenter {
    
    weak var view: AnalyticsViewInterface?
    let model: AnalyticsViewModel
    
    init(view: AnalyticsViewInterface) {
        self.view = view
        self.model = AnalyticsViewModel()
        model.delegate = self
    }
    
    func postContact() {
        guard let formValues = view?.formValue else {return}
        model.postContact(formValues: formValues)
    }
    
}

extension AnalyticsViewPresenter: AnalyticsViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
