//
//  WageViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class WageViewPresenter {
    
    weak var view: WageViewInterface?
    let model: WageViewModel
    
    init(view: WageViewInterface) {
        self.view = view
        self.model = WageViewModel()
        model.delegate = self
    }
    
    func getUserWage() -> UserWage {
        return model.userWage
    }
    
    func setUserWage() {
        model.setUserWage()
    }
    
    func updateUserWage() {
        guard let daytimeStart = view?.daytimeStart else {return }
        guard let daytimeEnd = view?.daytimeEnd else {return }
        guard let nightStart = view?.nightStart else {return }
        guard let nightEnd = view?.nightEnd else {return }
        guard let daytimeWage = view?.daytimeWage else {return }
        guard let nightWage = view?.nightWage else {return }
        
        model.updateUserWage(daytimeStart: daytimeStart, daytimeEnd: daytimeEnd, nightStart: nightStart, nightEnd: nightEnd, daytimeWage: daytimeWage, nightWage: nightWage)
    }
}

extension WageViewPresenter: WageViewModelDelegate {
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
