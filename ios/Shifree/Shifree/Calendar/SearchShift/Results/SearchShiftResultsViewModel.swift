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
    
    func isToday(index: Int) -> Bool {
        let today = getFormatterStringFromDate(format: "yyyy-MM-dd", date: Date())
        let date = searchResults[index]["date"] as! String
        
        return today == date
    }
}
