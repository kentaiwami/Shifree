//
//  ExportViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class ExportViewPresenter {
    
    weak var view: ExportViewInterface?
    let model: ExportViewModel
    
    init(view: ExportViewInterface) {
        self.view = view
        self.model = ExportViewModel()
        model.delegate = self
    }
}

extension ExportViewPresenter: ExportViewModelDelegate {}
