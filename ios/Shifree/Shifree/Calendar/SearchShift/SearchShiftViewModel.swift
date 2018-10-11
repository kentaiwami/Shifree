//
//  SearchShiftViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol SearchShiftViewModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class SearchShiftViewModel {
    weak var delegate: SearchShiftViewModelDelegate?
    private let api = API()
    private(set) var users:[MinimumInfoUser] = []
    private(set) var tables:[FileTable] = []
    private(set) var shifts:[Shift] = []
    private(set) var categories:[ShiftCategory] = []
    
    func setInitData() {
        api.getShiftSearchInitData().done { (json) in
            self.categories = json["results"]["category"].arrayValue.map({ (category) in
                return ShiftCategory.init(id: category["id"].intValue, name: category["name"].stringValue)
            })
            
            self.shifts = json["results"]["shift"].arrayValue.map({ (shift) in
                return Shift.init(id: shift["id"].intValue, name: shift["name"].stringValue)
            })
            
            self.users = json["results"]["user"].arrayValue.map({ (user) in
                return MinimumInfoUser.init(name: user["name"].stringValue, id: user["id"].intValue)
            })
            
            self.tables = json["results"]["table"].arrayValue.map({ (table) in
                return FileTable.init(id: table["id"].intValue, title: table["title"].stringValue, origin: "", thumbnail: "")
            })
            
            self.categories.insert(ShiftCategory.init(id: -1, name: "指定なし"), at: 0)
            self.shifts.insert(Shift.init(id: -1, name: "指定なし"), at: 0)
            self.users.insert(MinimumInfoUser.init(name: "指定なし", id: -1), at: 0)
            self.tables.insert(FileTable.init(id: -1, title: "指定なし", origin: "", thumbnail: ""), at: 0)
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getUsers() -> [String] {
        return users.map({ (user) in
            user.name
        })
    }
    
    func getCategories() -> [String] {
        return categories.map({ (category) in
            category.name
        })
    }
    
    func getShifts() -> [String] {
        return shifts.map({ (shift) in
            shift.name
        })
    }
    
    func getTables() -> [String] {
        return tables.map({ (table) in
            table.title
        })
    }
}
