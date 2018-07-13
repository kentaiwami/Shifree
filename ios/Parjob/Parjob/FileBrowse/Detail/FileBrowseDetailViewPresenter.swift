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
    
    func getComments() -> [Comment] {
        return model.commentList
    }
    
    func isMyComment(row: Int) -> Bool {
        return model.isMyComment(row: row)
    }
    
    func deleteFileTable() {
        guard let tableID = view?.tableID else {return}
        model.deleteTable(tableID: tableID)
    }
    
    func isAdmin() -> Bool {
        return model.isAdmin()
    }
}

extension FileBrowseDetailViewPresenter: FileBrowseDetailViewModelDelegate {
    func successDelete() {
        view?.popView()
    }
    
    func initializeUI() {
        view?.initializeUI()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
