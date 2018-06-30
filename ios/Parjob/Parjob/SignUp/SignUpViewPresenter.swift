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
    let signUpModel: SignUpModel
    
    init(view: SignUpViewInterface) {
        self.view = view
        self.signUpModel = SignUpModel()
        signUpModel.delegate = self
    }

    func signUpButtonTapped() {
        guard let companyCode = view?.companyCode else  { return }
        guard let userCode = view?.userCode else  { return }
        guard let userName = view?.userName else  { return }
        guard let password = view?.password else  { return }
        signUpModel.signUp(companyCode: companyCode, userCode: userCode, userName: userName, password: password)
    }
}

extension SignUpViewPresenter: SignUpModelDelegate {
    func successSignUp() {
        view?.navigateCalendar()
    }
    
    func faildSignUp(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
