//
//  AddCommentViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess
import PromiseKit
import SwiftyJSON


protocol AddCommentViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}


class AddCommentViewModel {
    weak var delegate: AddCommentViewModelDelegate?
    private let api = API()
    
    func addComment(formValue: [String:Any?], tableID: Int) {
        let text = formValue["Comment"] as! String
        
        api.addComment(text: text, id: tableID).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
