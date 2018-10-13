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
}
