//
//  UserTopViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class UserTopViewPresenter {
    
    weak var view: UserTopViewInterface?
    let model: UserTopViewModel
    
    init(view: UserTopViewInterface) {
        self.view = view
        self.model = UserTopViewModel()
        model.delegate = self
    }
    
    func isAdmin() -> Bool {
        return model.isAdmin()
    }
    
    func tapResetButton() {
        model.resetUser()
    }
}

extension UserTopViewPresenter: UserTopViewModelDelegate {
    func navigateSignUp() {
        view?.navigateSignUp()
    }
}
