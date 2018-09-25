//
//  FollowSettingViewPresenter.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class FollowSettingViewPresenter {
    
    weak var view: FollowSettingViewInterface?
    let model: FollowSettingViewModel
    
    init(view: FollowSettingViewInterface) {
        self.view = view
        self.model = FollowSettingViewModel()
        model.delegate = self
    }
    
    func setFollowUserAndComapnyUsers() {
        model.setFollowUserAndCompanyUsers()
    }
    
    func getFollowUserAndComapnyUsers() -> (companyUsers: [String], followUser: String) {
        return (model.companyUsers, model.followUser)
    }
    
    func isFollowing() -> Bool {
        return model.isFollowing()
    }
    
    func getFollowingUsername() -> String? {
        return model.getFollowingUsername()
    }
    
    func updateFollow() {
        guard let formValue = view?.formValue else {return}
        model.updateFollow(formValue: formValue)
    }
}

extension FollowSettingViewPresenter: FollowSettingViewModelDelegate {
    func successUpdate() {
        view?.successUpdate()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    

    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
