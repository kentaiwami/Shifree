//
//  CalendarEntity.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/29.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

struct TableViewShift {
    var joined: String = ""
    var shifts: [UserShift] = []
    
    mutating func generateJoinedString() {
        var tmp = ""
        self.shifts.forEach { (userShift) in
            tmp += userShift.user + " "
        }
        
        joined = tmp.substring(to: tmp.index(before: tmp.endIndex))
    }
}

struct UserShift {
    var id: Int = 0
    var name: String = ""
    var user: String = ""
}

struct ShiftCategory {
    var name: String = ""
    var userShift: [UserShift] = []
}

struct TargetUserShift {
    var id: Int = 0
    var name: String = ""
    var color: String = ""
}

struct OneDayShift {
    var date: String = ""
    var memo: String = ""
    var shift: [ShiftCategory] = []
    var user: TargetUserShift = TargetUserShift()
}

struct ShiftCategoryColor {
    var name: String = ""
    var color: String = ""
}
