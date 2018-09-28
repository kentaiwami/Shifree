//
//  ContactViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol ContactViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}

class ContactViewModel {
    weak var delegate: ContactViewModelDelegate?
    private let api = API()
    
    func postContact(formValues: [String:Any?]) {
        print("++++++++++++++++++++++++++++")
        print(formValues)
        print("++++++++++++++++++++++++++++")
//        api.updateUserName(newUserName: newUserName).done { (json) in
//            let keychain = Keychain()
//            try! keychain.set(json["name"].stringValue, key: "userName")
//            self.delegate?.success()
//        }
//        .catch { (err) in
//            let tmp_err = err as NSError
//            let title = "Error(" + String(tmp_err.code) + ")"
//            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
//        }
    }
}
