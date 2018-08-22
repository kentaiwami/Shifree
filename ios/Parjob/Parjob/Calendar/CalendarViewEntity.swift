//
//  CalendarViewEntity.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/29.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

struct TableViewShift {
    var joined: String = ""
    var shifts: [UserShift] = []
    
    mutating func generateJoinedString(tartgetUserShift: TargetUserShift, memo: String) {
        let targetUserShift = self.shifts.filter({$0.id == tartgetUserShift.id})
        var tmp = ""
        
        // ユーザのシフト情報がある箇所だけ、ユーザ名とコメントを分けるように文字列を操作
        if targetUserShift.count == 0 {
            self.shifts.forEach { (userShift) in
                tmp += userShift.user + "(" + userShift.name + ")　"
            }
            joined = String(tmp[tmp.startIndex..<tmp.index(before: tmp.endIndex)])
        }else {
            for userShift in self.shifts {
                if userShift.id != targetUserShift[0].id {
                    tmp += userShift.user + "(" + userShift.name + ")　"
                }
            }
            
            if tmp.count == 0 {
                joined = targetUserShift[0].user + "(" + targetUserShift[0].name + ")"
                
                if memo.count != 0 {
                    joined += "\n" + memo
                }
            }else {
                var newLine = "\n"
                if memo.count != 0 {
                    newLine += "\n"
                }
                
                joined = targetUserShift[0].user + "(" + targetUserShift[0].name + ")" + "\n" + memo + newLine + tmp
            }
        }
    }
}

struct UserShift {
    var id: Int = 0
    var name: String = ""
    var user: String = ""
}

struct ShiftCategoryWithUserShift {
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
    var shift: [ShiftCategoryWithUserShift] = []
    var user: TargetUserShift = TargetUserShift()
}
