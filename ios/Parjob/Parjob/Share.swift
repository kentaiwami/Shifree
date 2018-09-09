//
//  Share.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/09/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation


/// 通知をタップしてアプリを起動した場合に、AppDelegateと他ViewController間で値を共有するのに使用
class MyApplication {
    static let shared = MyApplication()
    private init() {}
    var updated: Date?
}
