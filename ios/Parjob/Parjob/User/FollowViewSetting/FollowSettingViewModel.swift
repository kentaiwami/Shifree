//
//  FollowSettingViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol FollowSettingViewModelDelegate: class {
    func initializeUI()
    func successUpdate()
    func faildAPI(title: String, msg: String)
}

class FollowSettingViewModel {
    weak var delegate: FollowSettingViewModelDelegate?
    private let api = API()
    private(set) var companyUsers: [String] = []
    private(set) var followUser: String = ""
    
    func setFollowUserAndCompanyUsers() {
        api.getFollowUserAndCompanyUsers().done { (json) in
            self.companyUsers = json["results"]["users"].arrayValue.map({$0.stringValue})
            self.followUser = json["results"]["follow"].stringValue
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func isFollowing() -> Bool {
        return followUser.count == 0 ? false:true
    }
    
    func getFollowingUsername() -> String? {
        return followUser.count == 0 ? companyUsers.first:followUser
    }
    
    func updateFollow(formValue: [String:Any?]) {
        var requestUsername = ""
        
        if let tmpUsername = formValue["username"] as? String {
            requestUsername = tmpUsername
        }
        
        api.updateFollow(username: requestUsername).done { (json) in
            self.delegate?.successUpdate()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
