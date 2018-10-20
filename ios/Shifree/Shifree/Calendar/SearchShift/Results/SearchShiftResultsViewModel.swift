//
//  SearchShiftResultsViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftResultsViewModelDelegate: class {
    func updateView()
    func showErrorAlert(title: String, msg: String)
}

class SearchShiftResultsViewModel {
    weak var delegate: SearchShiftResultsViewModelDelegate?
    private let api = API()
    
    private(set) var searchResults:[[String:Any]] = []
    private(set) var query:[String:Int] = [:]
    private(set) var prevControllerisDetailView = false
    
    func setData(results: [[String:Any]], query: [String:Int]) {
        searchResults = results
        self.query = query
    }
    
    func getJoinString(index: Int) -> String {
        let userShifts = searchResults[index]["shift"] as! [UserShift]
        var joined = ""
        
        userShifts.forEach { (userShift) in
            joined += "\(userShift.user)(\(userShift.name)) "
        }
        joined = String(joined[joined.startIndex..<joined.index(before: joined.endIndex)])
        return joined
    }
    
    func getTableViewShift(index: Int) -> TableViewShift {
        var tmpTableViewShift = TableViewShift()
        let userShifts = searchResults[index]["shift"] as! [UserShift]
        
        userShifts.forEach { (userShift) in
            tmpTableViewShift.shifts.append(UserShift.init(id: userShift.id, name: userShift.name, user: userShift.user))
        }
        
        return tmpTableViewShift
    }
    
    func getHeaderString(index: Int) -> String {
        let dateStr = searchResults[index]["date"] as! String
        let date = getFormatterDateFromString(format: "yyyy-MM-dd", dateString: dateStr)
        let calendar = Calendar.current
        let component = calendar.component(.weekday, from: date)
        let weekday = component - 1
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja")
        
        return "\(dateStr)(\(formatter.shortWeekdaySymbols[weekday]))"
    }
    
    func isBeforeToday(index: Int) -> Bool {
        let date = getFormatterDateFromString(format: "yyyy-MM-dd", dateString: searchResults[index]["date"] as! String)
        
        if isToday(index: index) {
            return false
        }
        
        return date < Date()
    }
    
    func isToday(index: Int) -> Bool {
        let today = getFormatterStringFromDate(format: "yyyy-MM-dd", date: Date())
        let date = searchResults[index]["date"] as! String
        
        return today == date
    }
    
    func setPrevControllerisDetailView(value: Bool) {
        prevControllerisDetailView = value
    }
    
    func updateData() {
        api.getShiftSearchResults(userID: query["userID"]!, categoryID: query["categoryID"]!, tableID: query["tableID"]!, shiftID: query["shiftID"]!).done { (json) in
            self.searchResults = json["results"].arrayValue.map({ oneDay in
                return [
                    "date": oneDay["date"].stringValue,
                    "shift": oneDay["shift"].arrayValue.map({ shift in
                        return UserShift.init(id: shift["id"].intValue, name: shift["name"].stringValue, user: shift["user"].stringValue)
                    })
                ]
            })
            
            self.delegate?.updateView()
            
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.showErrorAlert(title: title, msg: tmp_err.domain)
        }
    }
}
