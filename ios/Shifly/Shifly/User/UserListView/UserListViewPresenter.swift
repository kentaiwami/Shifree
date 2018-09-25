//
//  UserListViewPresenter.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class UserListViewPresenter {
    
    weak var view: UserListViewInterface?
    let model: UserListViewModel
    
    init(view: UserListViewInterface) {
        self.view = view
        self.model = UserListViewModel()
        model.delegate = self
    }
    
    func setUserList() {
        model.setUserList()
    }
    
    func getUserList() -> [User] {
        return model.userList
    }
}

extension UserListViewPresenter: UserListViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
