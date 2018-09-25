//
//  FileBrowseTopViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol FileBrowseTopViewModelDelegate: class {
    func initializeUI()
    func updateView()
    func faildAPI(title: String, msg: String)
}

class FileBrowseTopViewModel {
    weak var delegate: FileBrowseTopViewModelDelegate?
    private let api = API()
    private(set) var fileTableList: [FileTable] = []
    fileprivate(set) var prevViewController: Any.Type = FileBrowseTopViewController.self
    
    func setFileTable(isUpdate: Bool) {
        fileTableList = []
        api.getFileTable().done { (json) in
            json["results"].arrayValue.forEach({ (fileTable) in
                self.fileTableList.append(
                    FileTable(id: fileTable["table_id"].intValue, title: fileTable["title"].stringValue, origin: fileTable["origin"].stringValue, thumbnail: fileTable["thumbnail"].stringValue)
                )
            })
            
            if isUpdate {
                self.delegate?.updateView()
            }else {
                self.delegate?.initializeUI()
            }
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getTable(index: Int) -> FileTable {
        if fileTableList.count == 0 {
            return FileTable()
        }else {
            return fileTableList[index]
        }
    }
    
    func isBackgroundViewHidden() -> Bool {
        if fileTableList.count == 0 {
            return false
        }else {
            return true
        }
    }
    
    func setPrevViewController(value: Any.Type) {
        prevViewController = value
    }
}
