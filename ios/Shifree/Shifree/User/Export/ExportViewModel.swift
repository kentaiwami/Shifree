//
//  ExportViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ExportViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class ExportViewModel {
    weak var delegate: ExportViewModelDelegate?
    private let api = API()
    private(set) var users:[ExportUser] = []
    private(set) var tables:[FileTable] = []
    private(set) var followUser: ExportUser = ExportUser()
    private(set) var me: ExportUser = ExportUser()
    
    func setInitData() {
        api.getExportInitData().done { (json) in
            let follow = json["follow"].dictionaryValue
            self.followUser = ExportUser()
            
            if let id = follow["id"]?.intValue {
                self.followUser.id = id
            }
            
            if let name = follow["name"]?.stringValue {
                self.followUser.name = name
            }
            
            self.me.id = (json["me"].dictionaryValue["id"]?.intValue)!
            self.me.name = (json["me"].dictionaryValue["name"]?.stringValue)!
            
            self.tables = json["tables"].arrayValue.map({ (table) in
                var tmp = FileTable()
                tmp.id = table["id"].intValue
                tmp.title = table["title"].stringValue
                return tmp
            })
            
            self.users = json["users"].arrayValue.map({ (user) in
                var tmp = ExportUser()
                tmp.id = user["id"].intValue
                tmp.name = user["name"].stringValue
                return tmp
            })
            
            self.delegate?.initializeUI()
            
        }.catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getTablesName() -> [String] {
        return tables.map({$0.title})
    }
    
    func getUsersName() -> [String] {
        return users.map({$0.name})
    }
    
    func getInitValue() -> String {
        if followUser.name.count != 0 {
            return followUser.name
        }
        
        return me.name
    }
    
    func export(formValue: [String:Any?]) {
        let tableTitle = formValue["table"] as! String
        let username = formValue["user"] as! String
        let tableID = tables.filter({$0.title == tableTitle}).first!.id
        let userID = users.filter({$0.name == username}).first!.id
        
        api.getExportShiftData(userID: userID, tableID: tableID).done { (json) in
            print(json)
        }.catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
