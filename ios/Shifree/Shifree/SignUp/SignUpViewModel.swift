//
//  SignUpViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess


protocol SignUpViewModelDelegate: class {
    func successSignUp()
    func faildAPI(title: String, msg: String)
}

class SignUpViewModel {
    weak var delegate: SignUpViewModelDelegate?
    private let api = API()
    
    func signUp(companyCode: String, userCode: String, userName: String, password: String) {
        let params = [
            "company_code": companyCode,
            "user_code": userCode,
            "username": userName,
            "password": password
            ] as [String : Any]

        api.signUp(params: params).done { (json) in
            let keychain = Keychain()
            try! keychain.set(json["user_id"].stringValue, key: "userId")
            try! keychain.set(companyCode, key: "companyCode")
            try! keychain.set(userCode, key: "userCode")
            try! keychain.set(userName, key: "userName")
            try! keychain.set(password, key: "password")
            
            self.delegate?.successSignUp()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
