//
//  SearchShiftViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftViewModelDelegate: class {
    func initializeUI()
    func showReConfirmAlert()
    func navigateResultsView()
    func showErrorAlert(title: String, msg: String)
}

class SearchShiftViewModel {
    weak var delegate: SearchShiftViewModelDelegate?
    private let api = API()
    private(set) var users:[MinimumInfoUser] = []
    private(set) var tables:[FileTable] = []
    private(set) var shifts:[Shift] = []
    private(set) var categories:[ShiftCategory] = []
    private(set) var searchResults:[[String:Any]] = []
    private(set) var query:[String:Int] = [:]
    
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
            self.delegate?.showErrorAlert(title: title, msg: tmp_err.domain)
        }
    }
    
    func search(formValue: [String:Any?], isForced: Bool) {
        let userID = users.filter({$0.name == formValue["user"] as! String}).first!.id
        let tableID = tables.filter({$0.title == formValue["table"] as! String}).first!.id
        var categoryID = -1
        var shiftID = -1
        
        if let categoryName = formValue["category"] as? String {
            categoryID = categories.filter({$0.name == categoryName}).first!.id
        }
        
        if let shiftName = formValue["shift"] as? String {
            shiftID = shifts.filter({$0.name == shiftName}).first!.id
        }
        
        if isForced {
            callSearchAPI(userID: userID, categoryID: categoryID, tableID: tableID, shiftID: shiftID)
        }else {
            if tableID == -1 {
                self.delegate?.showReConfirmAlert()
            }else {
                callSearchAPI(userID: userID, categoryID: categoryID, tableID: tableID, shiftID: shiftID)
            }
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


// MARK: - 検索実行の関数（可読性のためにextension）
extension SearchShiftViewModel {
    fileprivate func callSearchAPI(userID: Int, categoryID: Int, tableID: Int, shiftID: Int) {
        api.getShiftSearchResults(userID: userID, categoryID: categoryID, tableID: tableID, shiftID: shiftID).done { (json) in
            if json["results"].arrayValue.count == 0 {
                self.delegate?.showErrorAlert(title: "エラー", msg: "検索結果が見つかりませんでした")
            }else {
                self.searchResults = json["results"].arrayValue.map({ oneDay in
                    return [
                        "date": oneDay["date"].stringValue,
                        "shift": oneDay["shift"].arrayValue.map({ shift in
                            return UserShift.init(id: shift["id"].intValue, name: shift["name"].stringValue, user: shift["user"].stringValue)
                        })
                    ]
                })
                
                self.query = ["userID": userID, "categoryID":categoryID, "tableID":tableID, "shiftID":shiftID]
                self.delegate?.navigateResultsView()
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.showErrorAlert(title: title, msg: tmp_err.domain)
        }
    }
}
