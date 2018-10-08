//
//  ExportViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ExportViewModelDelegate: class {}

class ExportViewModel {
    weak var delegate: ExportViewModelDelegate?
}
