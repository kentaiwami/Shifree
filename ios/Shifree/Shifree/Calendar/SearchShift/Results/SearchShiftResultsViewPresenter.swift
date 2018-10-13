//
//  SearchShiftResultsViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class SearchShiftResultsViewPresenter {
    
    weak var view: SearchShiftResultsViewInterface?
    let model: SearchShiftResultsViewModel
    
    init(view: SearchShiftResultsViewInterface) {
        self.view = view
        self.model = SearchShiftResultsViewModel()
        model.delegate = self
    }
    
    func setResults(results: [[String:Any]]) {
        model.setResults(results: results)
    }
    
    func getResultsCount() -> Int {
        return model.searchResults.count
    }
    
    func getDateString(index: Int) -> String {
        return model.searchResults[index]["date"] as! String
    }
    
    func getJoinString(index: Int) -> String {
        return model.getJoinString(index: index)
    }
    
    func getTableViewShift(index: Int) -> TableViewShift {
        return model.getTableViewShift(index: index)
    }
    
    func getTitle(index: Int) -> String {
        return model.getTitle(index: index)
    }
    
    func isToday(index: Int) -> Bool {
        return model.isToday(index: index)
    }
    
}

extension SearchShiftResultsViewPresenter: SearchShiftResultsViewModelDelegate {}
