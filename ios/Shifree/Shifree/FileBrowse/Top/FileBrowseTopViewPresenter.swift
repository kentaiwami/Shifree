//
//  FileBrowseTopViewPresenter.swift
//  Shifree
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
        
    func setFileTable(isUpdate: Bool) {
        model.setFileTable(isUpdate: isUpdate)
    }
    
    func getTableCount() -> Int {
        return model.fileTableList.count
    }
    
    func isBackgroundViewHidden() -> Bool {
        return model.isBackgroundViewHidden()
    }
    
    func getTable(index: Int) -> FileTable {
        return model.getTable(index: index)
    }
    
    func getPrevViewController() -> Any.Type {
        return model.prevViewController
    }
    
    func setPrevViewController(value: Any.Type) {
        model.setPrevViewController(value: value)
    }
}

extension FileBrowseTopViewPresenter: FileBrowseTopViewModelDelegate {
    func initializeUI() {
        view?.initializeUI()
    }
    
    func updateView() {
        view?.updateView()
    }
    
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
}
