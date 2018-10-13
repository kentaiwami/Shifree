//
//  SearchShiftResultsViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol SearchShiftResultsViewPresentable: class {
    var username: String { get }
}

class SearchShiftResultsViewPresenter {
    
    weak var view: SearchShiftResultsViewInterface?
    let model: SearchShiftResultsViewModel
    
    init(view: SearchShiftResultsViewInterface) {
        self.view = view
        self.model = SearchShiftResultsViewModel()
        model.delegate = self
    }
    
    func postContact() {
        guard let formValues = view?.formValue else {return}
        model.postContact(formValues: formValues)
    }
    
}

extension SearchShiftResultsViewPresenter: SearchShiftResultsViewModelDelegate {
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
