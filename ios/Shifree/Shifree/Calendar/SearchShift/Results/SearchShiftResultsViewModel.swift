//
//  SearchShiftResultsViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftResultsViewModelDelegate: class {}

class SearchShiftResultsViewModel {
    weak var delegate: SearchShiftResultsViewModelDelegate?
    private(set) var searchResults:[[String:Any]] = []
    
    func setResults(results: [[String:Any]]) {
        searchResults = results
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
    
    func getTitle(index: Int) -> String {
        return searchResults[index]["date"] as! String
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
}
