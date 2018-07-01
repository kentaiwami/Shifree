//
//  UserTopViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class UserTopViewPresenter {
    
    weak var view: UserTopViewInterface?
    let userTopModel: UserTopModel
    
    init(view: UserTopViewInterface) {
        self.view = view
        self.userTopModel = UserTopModel()
    }
    
    func isAdmin() -> Bool {
        return userTopModel.isAdmin()
    }
}
