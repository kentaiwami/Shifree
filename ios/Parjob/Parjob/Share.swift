//
//  Share.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/09/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

class MyApplication {
    static let shared = MyApplication()
    private init() {}
    var updated: Date?
}
