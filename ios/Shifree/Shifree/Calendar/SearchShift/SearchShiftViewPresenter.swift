//
//  SearchShiftViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftViewPresentable: class {
    var username: String { get }
}

class SearchShiftViewPresenter {
    
    weak var view: SearchShiftViewInterface?
    let model: SearchShiftViewModel
    
    init(view: SearchShiftViewInterface) {
        self.view = view
        self.model = SearchShiftViewModel()
        model.delegate = self
    }
    
    func setInitData() {
        model.setInitData()
    }
    
    func getUsers() -> [String] {
        return model.getUsers()
    }
    
    func getCategories() -> [String] {
        return model.getCategories()
    }
    
    func getShifts() -> [String] {
        return model.getShifts()
    }
    
    func getTables() -> [String] {
        return model.getTables()
    }
    
}

extension SearchShiftViewPresenter: SearchShiftViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
