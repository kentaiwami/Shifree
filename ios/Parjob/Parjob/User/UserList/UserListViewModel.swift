//
//  UserListViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol UserListViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class UserListViewModel {
    weak var delegate: UserListViewModelDelegate?
    private let api = API()
    private(set) var userList: [User] = []
    
    func setUserList() {
        api.getUserList().done { (json) in
            json["results"].arrayValue.forEach({ (userJson) in
                var tmpUser = User()
                tmpUser.name = userJson["name"].stringValue
                tmpUser.code = userJson["code"].stringValue
                tmpUser.order = userJson["order"].intValue
                tmpUser.role = userJson["role"].stringValue
                tmpUser.password = userJson["password"].stringValue
                
                self.userList.append(tmpUser)
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    //TODO: delete, addを判別
    func updateUserList(formValues: [String:Any?]) {
        //TODO:
        let add = formValues.filter({$0.key.contains("_new")})
        //add valueからユーザ名と権限を抽出できたもの
        print(add)
        //delete formValuesになくてuserListにあるmono
        
    }
    
}



// MARK: - 記述簡略化のため関数化
extension UserListViewModel  {
    func getNoNullableDict(nullableDict: [String:Any?]) -> [String:Any] {
        let dict = nullableDict.reduce([String : Any]()) { (dict, e) in
            guard let value = e.1 else { return dict }
            var dict = dict
            dict[e.0] = value
            return dict
        }
        return dict
    }
    
    func getNumber(mixText: String) -> Int {
        let splitNumbers = (mixText.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let number = splitNumbers.joined()
        
        return Int(number)!
    }
}
