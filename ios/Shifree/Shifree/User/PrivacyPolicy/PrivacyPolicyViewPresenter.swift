//
//  PrivacyPolicyViewPresenter.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class PrivacyPolicyViewPresenter {
    
    weak var view: PrivacyPolicyViewInterface?
    let model: PrivacyPolicyViewModel
    
    init(view: PrivacyPolicyViewInterface) {
        self.view = view
        self.model = PrivacyPolicyViewModel()
        model.delegate = self
    }
    
    func getURLRequest() -> URLRequest {
        return model.urlRequest
    }
}

extension PrivacyPolicyViewPresenter: PrivacyPolicyViewModelDelegate {}
