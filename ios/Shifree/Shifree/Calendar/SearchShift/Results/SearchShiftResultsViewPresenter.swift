//
//  SearchShiftResultsViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftResultsViewPresentable: class {}

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
    
}

extension SearchShiftResultsViewPresenter: SearchShiftResultsViewModelDelegate {}
