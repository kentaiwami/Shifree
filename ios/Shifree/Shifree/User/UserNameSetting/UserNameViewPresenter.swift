//
//  UserNameViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol UserNameViewPresentable: class {
    var username: String { get }
}

class UserNameViewPresenter {
    
    weak var view: UserNameViewInterface?
    let model: UserNameViewModel
    
    init(view: UserNameViewInterface) {
        self.view = view
        self.model = UserNameViewModel()
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

extension UserNameViewPresenter: UserNameViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
