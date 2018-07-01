//
//  WageViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol WageViewPresentable: class {
    var username: String { get }
}

class WageViewPresenter {
    
    weak var view: WageViewInterface?
    let model: WageViewModel
    
    init(view: WageViewInterface) {
        self.view = view
        self.model = WageViewModel()
        model.delegate = self
    }
    
    var username: String {
        return model.getUsername()
    }
    
    func updateUserName() {
        guard let username = view?.username else {return }
        model.updateUserName(newUserName: username)
    }
}

extension WageViewPresenter: WageViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
