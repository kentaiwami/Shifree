//
//  PrivacyPolicyViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class PrivacyPolicyViewPresenter {
    
    weak var view: PrivacyPolicyViewInterface?
    let model: PrivacyPolicyViewModel
    
    init(view: PrivacyPolicyViewInterface) {
        self.view = view
        self.model = PrivacyPolicyViewModel()
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

extension PrivacyPolicyViewPresenter: PrivacyPolicyViewModelDelegate {
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
