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
    
    func setData(results: [[String:Any]], query: [String:Int]) {
        model.setData(results: results, query: query)
    }
    
    func getResultsCount() -> Int {
        return model.searchResults.count
    }
    
    func getHeaderString(index: Int) -> String {
        return model.getHeaderString(index: index)
    }
    
    func getJoinString(index: Int) -> String {
        return model.getJoinString(index: index)
    }
    
    func getTableViewShift(index: Int) -> TableViewShift {
        return model.getTableViewShift(index: index)
    }
    
    func isBeforeToday(index: Int) -> Bool {
        return model.isBeforeToday(index: index)
    }
    
    func isToday(index: Int) -> Bool {
        return model.isToday(index: index)
    }
    
    func setPrevControllerisDetailView(value: Bool) {
        return model.setPrevControllerisDetailView(value: value)
    }
    
    func getPrevControllerisDetailView() -> Bool {
        return model.prevControllerisDetailView
    }
    
    func updateData() {
        model.updateData()
    }
}

extension SearchShiftResultsViewPresenter: SearchShiftResultsViewModelDelegate {
    func updateView() {
        view?.updateView()
    }
    
    func showErrorAlert(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
