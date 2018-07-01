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
    let userNameModel: UserNameModel
    
    init(view: WageViewInterface) {
        self.view = view
        self.userNameModel = UserNameModel()
        userNameModel.delegate = self
    }
    
    var username: String {
        return userNameModel.getUsername()
    }
    
    func updateUserName() {
        guard let username = view?.username else {return }
        userNameModel.updateUserName(newUserName: username)
    }
    
}

extension WageViewPresenter: UserNameModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
