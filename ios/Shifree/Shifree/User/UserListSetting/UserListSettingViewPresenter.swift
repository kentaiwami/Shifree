//
//  UserListSettingViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class UserListSettingViewPresenter {
    
    weak var view: UserListSettingViewInterface?
    let model: UserListSettingViewModel
    
    init(view: UserListSettingViewInterface) {
        self.view = view
        self.model = UserListSettingViewModel()
        model.delegate = self
    }
    
    func setUserList() {
        model.setUserList()
    }
    
    func getUserList() -> [User] {
        return model.userList
    }
    
    func updateUserList() {
        guard let formValues = view?.formValues else {return }
        model.updateUserList(formValues: formValues)
    }
}

extension UserListSettingViewPresenter: UserListSettingViewModelDelegate {
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
