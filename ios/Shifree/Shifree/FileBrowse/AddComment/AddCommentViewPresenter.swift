//
//  AddCommentViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/06/28.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


class AddCommentViewPresenter {
    
    weak var view: AddCommentViewInterface?
    let model: AddCommentViewModel
    
    init(view: AddCommentViewInterface) {
        self.view = view
        self.model = AddCommentViewModel()
        model.delegate = self
    }
    
    func setTableID(id: Int) {
        model.setTableID(id: id)
    }
    
    func tapEditDoneButton() {
        guard let formValue = view?.formValues else { return }
        model.addComment(formValue: formValue)
    }
}

extension AddCommentViewPresenter: AddCommentViewModelDelegate {
    func faildAPI(title: String, msg: String) {
        view?.showErrorAlert(title: title, msg: msg)
    }
    
    func success() {
        view?.popupViewController()
    }
}

