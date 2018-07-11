//
//  UserListSettingViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol UserListSettingViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class UserListSettingViewModel {
    weak var delegate: UserListSettingViewModelDelegate?
    private let api = API()
    private(set) var userList: [User] = []
    
    func setUserList() {
        api.getUserList().done { (json) in
            json["results"]["users"].arrayValue.forEach({ (userJson) in
                var tmpUser = User()
                tmpUser.name = userJson["name"].stringValue
                tmpUser.code = userJson["code"].stringValue
                tmpUser.order = userJson["order"].intValue
                tmpUser.role = userJson["role"].stringValue
                tmpUser.password = userJson["password"].stringValue
                
                self.userList.append(tmpUser)
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateUserList(formValues: [String]) {
        var tmpUserList: [User] = userList
        var adds: [[String:Any]] = []
        var deletes: [String] = []
        var updates: [[String:Any]] = []
        
        for (i, value) in formValues.enumerated() {
            // ["ユーザ名", "権限", "ユーザコード"]に分割
            let split = value.components(separatedBy: ",")

            if split.count != 3 {
                continue
            }
            
            // 新規ユーザはコードが未配布で空文字
            if split[2].count == 0 {
                adds.append(["name": split[0], "role": split[1], "order": i+1])
                
            }else {
                let searchResult = tmpUserList.filter({$0.code == split[2]})
                if searchResult[0].role != split[1] || searchResult[0].order != i+1 {
                    updates.append(["user_code": split[2], "role": split[1], "order": i+1])
                }
                // 残ったものを削除されたものと判別するため、対象となったUserオブジェクトを削除
                let index = tmpUserList.indices.filter({tmpUserList[$0].code == searchResult[0].code}).first!
                tmpUserList.remove(at: index.advanced(by: 0))
            }
        }
        
        tmpUserList.forEach { (user) in
            deletes.append(user.code)
        }
        
        api.updateUserList(adds: adds, updates: updates, deletes: deletes).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
}
