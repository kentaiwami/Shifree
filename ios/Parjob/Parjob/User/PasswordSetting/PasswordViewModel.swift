//
//  PasswordViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol PasswordViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}

class PasswordViewModel {
    weak var delegate: PasswordViewModelDelegate?
    private let api = API()
    
    func updatePassword(now: String, new: String) {
        let keychain = Keychain()
        if try! keychain.get("password")! != now {
            self.delegate?.faildAPI(title: "Error", msg: "パスワードが違います")
        }else {
            api.updatePassword(new: new).done { (json) in
                try! keychain.set(new, key: "password")
                self.delegate?.success()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }
    }
}
