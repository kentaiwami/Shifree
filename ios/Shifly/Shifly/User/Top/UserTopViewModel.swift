//
//  UserTopViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol UserTopViewModelDelegate: class {
    func navigateSignUp()
}

class UserTopViewModel {
    weak var delegate: UserTopViewModelDelegate?
    
    func isAdmin() -> Bool {
        let keychain = Keychain()
        let role = try! keychain.get("role")!
        
        if role == "admin" {
            return true
        }else {
            return false
        }
    }
    
    func resetUser() {
        let keychain = Keychain()
        try! keychain.removeAll()
        self.delegate?.navigateSignUp()
    }
}
