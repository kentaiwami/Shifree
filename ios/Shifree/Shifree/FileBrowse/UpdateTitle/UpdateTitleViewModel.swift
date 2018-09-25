//
//  UpdateTitleViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol UpdateTitleViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}


class UpdateTitleViewModel {
    weak var delegate: UpdateTitleViewModelDelegate?
    private let api = API()
    
    func updateTitle(formValue: [String:Any?], tableID: Int) {
        let params = ["title": formValue["Title"] as! String]
        
        api.updateTableTitle(id: tableID, params: params).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
