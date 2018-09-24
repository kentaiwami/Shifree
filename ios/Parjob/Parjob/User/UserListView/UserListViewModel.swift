//
//  UserListViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol UserListViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class UserListViewModel {
    weak var delegate: UserListViewModelDelegate?
    private let api = API()
    private(set) var userList: [User] = []
    
    func setUserList() {
        api.getUserList().done { (json) in
            self.userList = json["results"]["users"].arrayValue.map({userJson in
                var tmpUser = User()
                tmpUser.name = userJson["name"].stringValue
                tmpUser.code = userJson["code"].stringValue
                tmpUser.order = userJson["order"].intValue
                tmpUser.role = userJson["role"].stringValue
                tmpUser.password = userJson["password"].stringValue
                return tmpUser
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
