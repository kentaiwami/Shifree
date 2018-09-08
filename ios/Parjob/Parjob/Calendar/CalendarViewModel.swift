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
    func updateView()
    func initializeUI()
    func faildAPI(title: String, msg: String)
}





class CalendarViewModel {
    weak var delegate: CalendarViewModelDelegate?
    fileprivate let api = API()
    let notificationCenter = NotificationCenter.default
    
    fileprivate(set) var oneDayShifts: [OneDayShift] = []
    fileprivate(set) var shiftCategoryColors: [ShiftCategoryColor] = []
    fileprivate(set) var tableViewShifts: [[TableViewShift]] = [[]]
    
    fileprivate(set) var currentPageDate: Date = Date()
    fileprivate(set) var currentDate: Date = Date()
    fileprivate(set) var start: Date = Date()
    fileprivate(set) var end: Date = Date()
    fileprivate(set) var updated: Date? = nil
    fileprivate(set) var currentScrollPage: Int = 0
    
    fileprivate(set) var tableCount: Int = 9
    fileprivate(set) var isTapedTabBar: Bool = false
    fileprivate(set) var isFirstTime: Bool = true
    fileprivate(set) var isSwipe: Bool = false
    fileprivate(set) var isReceiveNotificationSetCurrentPage: Bool = false
    fileprivate(set) var prevViewController: Any.Type = CalendarViewController.self
    
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
    
    func isSameDate(targetDate1: Date, targetDate2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(targetDate1, inSameDayAs: targetDate2)
    }
    
    func resetValues() {
        oneDayShifts = []
        shiftCategoryColors = []
        tableViewShifts = [[]]
        
        currentPageDate = Date()
        currentDate = Date()
        start = Date()
        end = Date()
        currentScrollPage = 0
    }
}


// MARK: - シフト関連
extension CalendarViewModel {
    func getAllUserShift() {
        let formattedStart = getFormatterStringFromDate(format: "yyyyMMdd", date: start)
        let formattedEnd = getFormatterStringFromDate(format: "yyyyMMdd", date: end)
        
        api.getUserShift(start: formattedStart, end: formattedEnd).done { (json) in
            self.oneDayShifts = self.getData(json: json)
            self.delegate?.updateView()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func setTableViewShift() {
        var count = -1
        var tmpDate = start
        let calendar = Calendar.current
        let endPlusOneDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end))!
        tableViewShifts = []
        
        while !calendar.isDate(endPlusOneDay, inSameDayAs: tmpDate) {
            tmpDate = calendar.date(byAdding: .day, value: count, to: calendar.startOfDay(for: start))!
            count += 1
            
            let tmpDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: tmpDate)
            let tmpDateOneDayShifts = oneDayShifts.filter {
                $0.date == tmpDateStr
            }
            
            if tmpDateOneDayShifts.count == 0 {
                tableViewShifts.append([])
            }else {
                var tmpTableViewShift: [TableViewShift] = []
                
                tmpDateOneDayShifts[0].shift.forEach { (shiftCategory) in
                    var tmp = TableViewShift()
                    
                    shiftCategory.userShift.forEach({ (userShift) in
                        tmp.shifts.append(userShift)
                    })
                    
                    tmp.generateJoinedString(tartgetUserShift: getTargetUserShift(date: tmpDate), memo: tmpDateOneDayShifts[0].memo)
                    tmpTableViewShift.append(tmp)
                }
                
                tableViewShifts.append(tmpTableViewShift)
            }
        }
    }
    
    func getTargetUserShift(date: Date?) -> TargetUserShift {
        /*
         dateがnil：ViewControllerからの呼び出し（currentDateを参照）
         それ以外  ：model内から日付を指定して呼び出し
         */
        var currentDate = Date()
        if date == nil {
            currentDate = self.currentDate
        }else {
            currentDate = date!
        }
        
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return TargetUserShift()
        }
        
        return currentDateOneDayShifts[0].user
    }
}



// MARK: - Start, End関連
extension CalendarViewModel {
    func setStartEndDate(start: Date, end: Date) {
        self.start = start
        self.end = end
    }
}



// MARK: - CurrentDate, CurrentPage関連
extension CalendarViewModel {
    func initCurrentDate() {
        if let updated = MyApplication.shared.updated {
            currentDate = updated
        }else {
            currentDate = Date()
        }
    }
    
    func setCurrentDate(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    func setCurrentPage(currentPage: Date) {
        self.currentPageDate = currentPage
    }
}



// MARK: - TableCount（表示するテーブルの個数。1週間の7つと左右の2つで9つ使用。）
extension CalendarViewModel {
    func setTableCount(isWeek: Bool) {
        if isWeek {
            tableCount = 9
        }else {
            tableCount = 44
        }
    }
}



// MARK: - IsTapedTabBar（タブバーをタップしてカレンダー操作をしたかどうか。ページ変更時のメソッドを発火させないため。）
extension CalendarViewModel {
    func setIsTapedTabBar(value: Bool) {
        isTapedTabBar = value
    }
}



// MARK: - IsFirstTime（boundingRectWillChangeは初回起動時に実行させないため。）
extension CalendarViewModel {
    func setIsFirstTime(value: Bool) {
        isFirstTime = value
    }
}


// MARK: - isSwipe（カレンダーのページが変化した際に、カレンダーをスワイプしたのか、テーブルをスワイプしたのか判定するために使用。）
extension CalendarViewModel {
    func setIsSwipe(value: Bool) {
        isSwipe = value
    }
}



// MARK: - isReceiveNotificationSetCurrentPage（通知を受信してカレンダーのページを更新した場合とスワイプ操作で更新した場合で、日付操作をスキップするために使用。）
extension CalendarViewModel {
    func setIsReceiveNotificationSetCurrentPage(value: Bool) {
        isReceiveNotificationSetCurrentPage = value
    }
}



// MARK: - prevViewController（タブバーがタップされた際の画面の型を保存。）
extension CalendarViewModel {
    func setPrevViewController(value: Any.Type) {
        prevViewController = value
    }
}



// MARK: - カレンダー関連
extension CalendarViewModel {
    func getUserColorSchemeForCalendar(targetDate: Date) -> String {
        let targetDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: targetDate)
        
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
    
    func getShouldSelectDate(currentPageDate: Date, isWeek: Bool) -> Date {
        var dayValue = 0
        var monthValue = 0
        let calendarCurrent = Calendar.current
        
        if self.currentPageDate < currentPageDate {
            dayValue = 7
            monthValue = 1
        }else {
            dayValue = -7
            monthValue = -1
        }
        
        if isWeek {
            return calendarCurrent.date(byAdding: .day, value: dayValue, to: currentDate)!
        }else {
            // 月を増減させたコンポーネントを作成
            var components = calendarCurrent.dateComponents([.year, .month, .day], from: currentDate)
            components.setValue(0, for: Calendar.Component.year)
            components.setValue(monthValue, for: Calendar.Component.month)
            components.setValue(0, for: Calendar.Component.day)
            
            /*
             選択している日から1ヶ月だけ増減させた日付を生成。
             日にちを1日（月初め）に変更。
             */
            let newDate = calendarCurrent.date(byAdding: components, to: currentDate)!
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



// MARK: - ScrollView関連
extension CalendarViewModel {
    func getScrollViewPosition(target: Date) -> Int {
        var position = 1
        var tmpDate = start
        let calendar = Calendar.current
        
        while !calendar.isDate(target, inSameDayAs: tmpDate) {
            tmpDate = calendar.date(byAdding: .day, value: position, to: calendar.startOfDay(for: start))!
            position += 1
        }
        
        return position
    }
    
    func setCurrentScrollPage(page: Int) {
        currentScrollPage = page
    }
    
    func getNewSelectDateByScroll(newScrollPage: Int) -> Date {
        let calendar = Calendar.current
        
        if newScrollPage < currentScrollPage {
            return calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: currentDate))!
        }else if newScrollPage > currentScrollPage {
            return calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: currentDate))!
        }else {
            return currentDate
        }
    }
}



// MARK: - TableView関連
extension CalendarViewModel {
    func getShiftCategories(tag: Int) -> [String] {
        let count = -1 + tag
        let calendar = Calendar.current
        let tmpDate = calendar.date(byAdding: .day, value: count, to: calendar.startOfDay(for: start))!
        let tmpDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: tmpDate)
        let tmpDateOneDayShifts = oneDayShifts.filter {
            $0.date == tmpDateStr
        }
        
        if tmpDateOneDayShifts.count == 0 {
            return []
        }
        
        var shiftCategories: [String] = []
        
        tmpDateOneDayShifts[0].shift.forEach { (shiftCategory) in
            shiftCategories.append(shiftCategory.name)
        }
        
        return shiftCategories
    }
    
    func getUserColorSchemeForTable(tag: Int) -> String {
        let count = -1 + tag
        let calendar = Calendar.current
        let tmpDate = calendar.date(byAdding: .day, value: count, to: calendar.startOfDay(for: start))!
        let tmpDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: tmpDate)
        
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == tmpDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        if currentDateOneDayShifts[0].user.color.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].user.color
    }
    
    func getUserSection(tag: Int) -> Int {
        let count = -1 + tag
        let calendar = Calendar.current
        let tmpDate = calendar.date(byAdding: .day, value: count, to: calendar.startOfDay(for: start))!
        let tmpDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: tmpDate)
        
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == tmpDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return 0
        }
        
        if currentDateOneDayShifts[0].user.id == 0 {
            return 0
        }
        
        for (i, tableViewShift) in tableViewShifts[tag].enumerated() {
            for userShift in tableViewShift.shifts {
                if currentDateOneDayShifts[0].user.id ==  userShift.id {
                    return i
                }
            }
        }
        return 0
    }
    
    func getMemo() -> String {
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        let currentDateOneDayShifts = oneDayShifts.filter {
            $0.date == currentDateStr
        }
        
        if currentDateOneDayShifts.count == 0 {
            return ""
        }
        
        return currentDateOneDayShifts[0].memo
    }
    
    func getTableViewScrollPosition(date: Date) -> (scrollPosition: IndexPath, tableViewPosition: Int) {
        let position = getScrollViewPosition(target: date)
        let userSection = getUserSection(tag: position)
        
        return (IndexPath(row: 0, section: userSection), position)
    }
}



// MARK: - Notification関連
extension CalendarViewModel {
    func setUpdated(object: Any?) {
        guard let dateDict = object as? [String:Date] else {
            updated = nil
            return
        }
        updated = dateDict["updated"]!
    }
}


// MARK: - Utility関連（見やすくするため関数化）
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
