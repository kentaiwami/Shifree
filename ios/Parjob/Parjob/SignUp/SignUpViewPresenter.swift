//
//  SignUpViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class SignUpViewPresenter {
    
    weak var view: SignUpViewInterface?
    let model: SignUpViewModel
    
    init(view: SignUpViewInterface) {
        self.view = view
        self.model = SignUpViewModel()
        model.delegate = self
    }

    func signUpButtonTapped() {
        guard let companyCode = view?.companyCode else  { return }
        guard let userCode = view?.userCode else  { return }
        guard let userName = view?.userName else  { return }
        guard let password = view?.password else  { return }
        model.signUp(companyCode: companyCode, userCode: userCode, userName: userName, password: password)
    }
}

extension SignUpViewPresenter: SignUpViewModelDelegate {
    func successSignUp() {
        view?.navigateCalendar()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
