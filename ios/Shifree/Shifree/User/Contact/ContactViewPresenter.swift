//
//  ContactViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ContactViewPresentable: class {
    var username: String { get }
}

class ContactViewPresenter {
    
    weak var view: ContactViewInterface?
    let model: ContactViewModel
    
    init(view: ContactViewInterface) {
        self.view = view
        self.model = ContactViewModel()
        model.delegate = self
    }
    
    var username: String {
        return model.getUsername()
    }
    
    func updateUserName() {
        guard let username = view?.username else {return }
        model.updateUserName(newUserName: username)
    }
    
}

extension ContactViewPresenter: ContactViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
