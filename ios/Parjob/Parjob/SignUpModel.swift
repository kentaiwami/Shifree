//
//  SignUpModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess


protocol SignUpModelDelegate: class {
    func successSignUp()
    func faildSignUp(title: String, msg: String)
}

class SignUpModel {
    weak var delegate: SignUpModelDelegate?
    private let api = API(version: "v1", endPoint: "auth")
    
    func signUp(companyCode: String, userCode: String, userName: String, password: String) {        
        api.SignUp(companyCode: companyCode, userCode: userCode, userName: userName, password: password).done { (json) in
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
            self.delegate?.faildSignUp(title: title, msg: tmp_err.domain)
        }
    }
}
