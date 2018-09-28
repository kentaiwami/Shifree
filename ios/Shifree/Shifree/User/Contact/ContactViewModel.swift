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
        let params = [
            "name": formValues["name"] as! String,
            "email": formValues["email"] as! String,
            "content": formValues["content"] as! String
        ]
        
        api.postContact(params: params).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
