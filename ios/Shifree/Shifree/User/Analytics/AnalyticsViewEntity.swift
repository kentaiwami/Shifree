//
//  FileBrowseTopViewEntity.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/07.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

struct AnalyticsResultFileTable {
    var start: String = ""
    var end: String = ""
    var title: String = ""
    var categories: [AnalyticsResultCategory] = []
}

struct AnalyticsResultCategory {
    var count: Int = 0
    var hex: String = ""
    var name: String = ""
}
