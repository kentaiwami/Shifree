//
//  FileBrowseTopViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class FileBrowseTopViewPresenter {
    
    weak var view: FileBrowseTopViewInterface?
    let model: FileBrowseTopViewModel
    
    init(view: FileBrowseTopViewInterface) {
        self.view = view
        self.model = FileBrowseTopViewModel()
        model.delegate = self
    }
        
    func setFileTable() {
        model.setFileTable()
    }
    
    func getTable() -> [FileTable] {
        return model.fileTableList
    }
}

extension FileBrowseTopViewPresenter: FileBrowseTopViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
