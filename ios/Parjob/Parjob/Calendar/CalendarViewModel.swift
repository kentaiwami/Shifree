//
//  CalendarViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/26.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess
import SwiftyJSON

protocol CalendarModelDelegate: class {
    func initializeUI()
    func faildAPI(title: String, msg: String)
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

struct OneDayShift {
    var date: String = ""
    var memo: String = ""
    var shift: [ShiftCategory] = []
}

class CalendarModel {
    
    
    weak var delegate: CalendarModelDelegate?
    private let api = API()
    private(set) var oneDayShifts: [OneDayShift] = []
    
    func login() {
        api.login().done { (json) in
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getUserShift(start: String, end: String) {
        api.getUserShift(start: start, end: end).done { (json) in
            self.oneDayShifts = self.getData(json: json)
            print(self.oneDayShifts.count)
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    private func getData(json: JSON) -> [OneDayShift] {
        var oneDayShift = [OneDayShift]()
        
        // 1日ごとにループ処理
        json["results"]["shift"].arrayValue.forEach { (shift) in
            var tmpOneDayShift = OneDayShift()
            tmpOneDayShift.date = shift["date"].stringValue
            tmpOneDayShift.memo = shift["memo"].stringValue
            
            // カテゴリごとにループ処理
            shift["shift_group"].arrayValue.forEach({ (shiftCategory) in
                let categoryDict = shiftCategory.dictionaryValue
                let categoryName = categoryDict.keys.first!
                
                var tmpShiftCategory = ShiftCategory()
                tmpShiftCategory.name = categoryName
                
                // カテゴリ内の1人ごとにループ処理
                (categoryDict[categoryName])!.arrayValue.forEach({ (userShift) in
                    let tmpUserShift = UserShift(
                        id: userShift["shift_id"].intValue,
                        name: userShift["shift_name"].stringValue,
                        user: userShift["user"].stringValue
                    )
                    tmpShiftCategory.userShift.append(tmpUserShift)
                })
                
                tmpOneDayShift.shift.append(tmpShiftCategory)
            })
            
            oneDayShift.append(tmpOneDayShift)
        }
        
        return oneDayShift
    }
}
