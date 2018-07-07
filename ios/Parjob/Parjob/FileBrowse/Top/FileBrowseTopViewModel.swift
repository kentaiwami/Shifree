//
//  FileBrowseTopViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol FileBrowseTopViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class FileBrowseTopViewModel {
    weak var delegate: FileBrowseTopViewModelDelegate?
    private let api = API()
    private(set) var fileTableList: [FileTable] = []
    
    func setFileTable() {
        fileTableList = []
        api.getFileTable().done { (json) in
            json["results"].arrayValue.forEach({ (fileTable) in
                self.fileTableList.append(
                    FileTable(id: fileTable["table_id"].stringValue, title: fileTable["title"].stringValue, origin: fileTable["origin"].stringValue, thumbnail: fileTable["thumbnail"].stringValue)
                )
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
