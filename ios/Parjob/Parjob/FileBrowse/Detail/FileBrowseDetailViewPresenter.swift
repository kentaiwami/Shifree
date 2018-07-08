//
//  FileBrowseDetailViewPresenter.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class FileBrowseDetailViewPresenter {
    
    weak var view: FileBrowseDetailViewInterface?
    let model: FileBrowseDetailViewModel
    
    init(view: FileBrowseDetailViewInterface) {
        self.view = view
        self.model = FileBrowseDetailViewModel()
        model.delegate = self
    }
        
    func setFileTableDetail() {
        guard let id = view?.tableID else { return }
        model.setFileTableDetail(id: id)
    }
    
    func getFileTable() -> FileTable {
        return model.fileTable
    }
}

extension FileBrowseDetailViewPresenter: FileBrowseDetailViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func success() {
        view?.success()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
