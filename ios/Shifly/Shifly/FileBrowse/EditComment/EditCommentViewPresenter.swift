//
//  EditCommentViewPresenter.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class EditCommentViewPresenter {
    
    weak var view: EditCommentViewInterface?
    let model: EditCommentViewModel
    
    init(view: EditCommentViewInterface) {
        self.view = view
        self.model = EditCommentViewModel()
        model.delegate = self
    }
    
    func setSelectedCommentData(comment: Comment) {
        model.setSelectedCommentData(comment: comment)
    }
    
    func getComment() -> Comment {
        return model.comment
    }
    
    func tapEditDoneButton() {
        guard let formValue = view?.formValues else { return }
        model.updateComment(formValue: formValue)
    }
}

extension EditCommentViewPresenter: EditCommentViewModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
    
    func success() {
        view?.popupViewController()
    }
}

