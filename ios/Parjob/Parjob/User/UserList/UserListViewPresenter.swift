//
//  UserListViewPresenter.swift
//  Parjob
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
    
    func updateUserList() {
        guard let formValues = view?.formValues else {return }
        model.updateUserList(formValues: formValues)
    }
}

extension UserListViewPresenter: UserListViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }

    func success() {
//        view?.success()
    }

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
