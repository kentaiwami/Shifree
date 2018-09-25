//
//  EditCommentViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol EditCommentViewModelDelegate: class {
    func success()
    func faildAPI(title: String, msg: String)
}


class EditCommentViewModel {
    weak var delegate: EditCommentViewModelDelegate?
    private let api = API()
    private(set) var comment: Comment!
    
    func setSelectedCommentData(comment: Comment) {
        self.comment = comment
    }
    
    func updateComment(formValue: [String:Any?]) {
        var text = ""
        if let tmpComment = formValue["Comment"] as? String {
            text = tmpComment
        }
        
        api.updateComment(text: text, id: comment.id).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
