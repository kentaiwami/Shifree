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

protocol CalendarViewModelDelegate: class {
    func updateTableViewData()
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class CalendarViewModel {
    weak var delegate: CalendarViewModelDelegate?
    private let api = API()
    private(set) var oneDayShifts: [OneDayShift] = []
    private(set) var shiftCategoryColors: [ShiftCategoryColor] = []
    private(set) var tableViewShifts: [TableViewShift] = []
    private(set) var currentPage: Date = Date()
    
    func login() {
        api.login().done { (json) in
            let keychain = Keychain()
            try! keychain.set(json["role"].stringValue, key: "role")
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getAllUserShift(start: Date, end: Date) {
        let formattedStart = getFormatterStringFromDate(format: "yyyyMMdd", date: start)
        let formattedEnd = getFormatterStringFromDate(format: "yyyyMMdd", date: end)
        
        api.getUserShift(start: formattedStart, end: formattedEnd).done { (json) in
            self.oneDayShifts = self.getData(json: json)
            self.delegate?.updateTableViewData()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func getShiftCategories(currentDate: Date) -> [String] {
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return []
        }
        
        var shiftCategories: [String] = []
        
        currentDateOneDayShifts[0].shift.forEach { (shiftCategory) in
            shiftCategories.append(shiftCategory.name)
        }
        return shiftCategories
    }
    
    func getCurrentAndPageDate() -> (currentPage: Date?, currentDate: Date) {
        if let sunday = MyApplication.shared.sunday {
            return (sunday, MyApplication.shared.updated!)
        }else {
            return (nil, Date())
        }
    }
    
    func setTableViewShift(currentDate: Date) {
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            self.tableViewShifts = []
        }else {
            var tmpTableViewShift: [TableViewShift] = []
            
            currentDateOneDayShifts[0].shift.forEach { (shiftCategory) in
                var tmp = TableViewShift()
                
                shiftCategory.userShift.forEach({ (userShift) in
                    tmp.shifts.append(userShift)
                })
                
                tmp.generateJoinedString(tartgetUserShift: getTargetUserShift(date: currentDate), memo: currentDateOneDayShifts[0].memo)
                tmpTableViewShift.append(tmp)
            }
            
            self.tableViewShifts = tmpTableViewShift
        }
    }
    
    func getUserColorScheme(date: Date) -> String {
        let targetDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: date)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == targetDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        if currentDateOneDayShifts[0].user.color.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].user.color
    }
    
    func getEventNumber(date: Date) -> Int {
        let targetDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: date)
        
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == targetDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return 0
        }
        
        if currentDateOneDayShifts[0].user.color.count == 0 || currentDateOneDayShifts[0].user.id == 0 || currentDateOneDayShifts[0].user.name.count == 0 {
            return 0
        }
        return 1
    }
    
    func getUserSection(date: Date) -> Int {
        let targetDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: date)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == targetDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return -1
        }
        
        if currentDateOneDayShifts[0].user.id == 0 {
            return -1
        }
        
        for (i, tableViewShift) in self.tableViewShifts.enumerated() {
            for userShift in tableViewShift.shifts {
                if currentDateOneDayShifts[0].user.id ==  userShift.id {
                    return i
                }
            }
        }
        return -1
    }
    
    func getMemo(date: Date) -> String {
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: date)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].memo
    }
    
    func getTargetUserShift(date: Date) -> TargetUserShift {
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: date)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return TargetUserShift()
        }
        
        return currentDateOneDayShifts[0].user
    }
    
    func setCurrentPage(currentPage: Date) {
        self.currentPage = currentPage
    }
    
    func getShouldSelectDate(currentPage: Date, selectingDate: Date, isWeek: Bool) -> Date {
        var dayValue = 0
        var monthValue = 0
        let calendarCurrent = Calendar.current
        
        if self.currentPage < currentPage {
            dayValue = 7
            monthValue = 1
        }else {
            dayValue = -7
            monthValue = -1
        }
        
        if isWeek {
            return calendarCurrent.date(byAdding: .day, value: dayValue, to: selectingDate)!
        }else {
            // 月を増減させたコンポーネントを作成
            var components = calendarCurrent.dateComponents([.year, .month, .day], from: selectingDate)
            components.setValue(0, for: Calendar.Component.year)
            components.setValue(monthValue, for: Calendar.Component.month)
            components.setValue(0, for: Calendar.Component.day)
            
            /*
             選択している日から1ヶ月だけ増減させた日付を生成。
             日にちを1日（月初め）に変更。
             */
            let newDate = calendarCurrent.date(byAdding: components, to: selectingDate)!
            components = calendarCurrent.dateComponents([.year, .month, .day], from: newDate)
            components.day = 1
            components.calendar = calendarCurrent
            
            if calendarCurrent.compare(Date(), to: components.date!, toGranularity: .year) == .orderedSame && calendarCurrent.compare(Date(), to: components.date!, toGranularity: .month) == .orderedSame {
                // スワイプ先が今月
                return Date()
            }else {
                return components.date!
            }
        }
    }
}


extension CalendarViewModel {
    fileprivate func getData(json: JSON) -> [OneDayShift] {
        var oneDayShift = [OneDayShift]()
        
        // 1日ごとにループ処理
        json["results"]["shift"].arrayValue.forEach { (shift) in
            var tmpOneDayShift = OneDayShift()
            tmpOneDayShift.date = shift["date"].stringValue
            tmpOneDayShift.memo = shift["memo"].stringValue
            tmpOneDayShift.user.color = shift["user_shift"]["color"].stringValue
            tmpOneDayShift.user.id = shift["user_shift"]["shift_id"].intValue
            tmpOneDayShift.user.name = shift["user_shift"]["shift_name"].stringValue
            
            // カテゴリごとにループ処理
            shift["shift_group"].arrayValue.forEach({ (shiftCategory) in
                let categoryDict = shiftCategory.dictionaryValue
                let categoryName = categoryDict.keys.first!
                
                var tmpShiftCategory = ShiftCategoryWithUserShift()
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
