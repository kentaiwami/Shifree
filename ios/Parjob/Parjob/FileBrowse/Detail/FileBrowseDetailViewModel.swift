//
//  FileBrowseDetailViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol FileBrowseDetailViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class FileBrowseDetailViewModel {
    weak var delegate: FileBrowseDetailViewModelDelegate?
    private let api = API()
    private(set) var fileTable: FileTable = FileTable()
    private(set) var commentList: [Comment] = []
    
    func setFileTableDetail(id: Int) {
        api.getFileTableDetail(id: id).done { (json) in
            self.fileTable.id = json["results"]["table_id"].intValue
            self.fileTable.origin = json["results"]["origin"].stringValue
            self.fileTable.title = json["results"]["title"].stringValue
            
            json["results"]["comment"].arrayValue.forEach({ (comment) in
                self.commentList.append(Comment(
                    id: comment["id"].intValue,
                    text: comment["text"].stringValue,
                    user: comment["user"].stringValue,
                    userID: comment["user_id"].intValue,
                    created: comment["created_at"].stringValue
                ))
            })
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }

}
