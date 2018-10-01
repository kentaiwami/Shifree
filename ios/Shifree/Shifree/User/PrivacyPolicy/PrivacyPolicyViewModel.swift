//
//  PrivacyPolicyViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol PrivacyPolicyViewModelDelegate: class {}

class PrivacyPolicyViewModel {
    weak var delegate: PrivacyPolicyViewModelDelegate?
    let urlRequest = URLRequest(url: URL(string: GetPortfolioHost() + "7/pp")!)
}
