//
//  ExportViewModel.swift
//  Shifree
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import EventKit
import SwiftyJSON

protocol ExportViewModelDelegate: class {
    func initializeUI()
    func showMessage(title: String, msg: String)
}

class ExportViewModel {
    weak var delegate: ExportViewModelDelegate?
    private let api = API()
    let eventStore = EKEventStore()
    
    private(set) var users:[MinimumInfoUser] = []
    private(set) var tables:[FileTable] = []
    private(set) var followUser: MinimumInfoUser = MinimumInfoUser()
    private(set) var me: MinimumInfoUser = MinimumInfoUser()
    private(set) var calendar:[UserCalendar] = []
    let format = ["ユーザ名+シフト名", "シフト名"]
    
    func setInitData() {
        setCalendars()
        
        api.getExportInitData().done { (json) in
            let follow = json["follow"].dictionaryValue
            self.followUser = MinimumInfoUser()
            
            if let id = follow["id"]?.intValue {
                self.followUser.id = id
            }
            
            if let name = follow["name"]?.stringValue {
                self.followUser.name = name
            }
            
            self.me.id = (json["me"].dictionaryValue["id"]?.intValue)!
            self.me.name = (json["me"].dictionaryValue["name"]?.stringValue)!
            
            self.tables = json["tables"].arrayValue.map({ (table) in
                var tmp = FileTable()
                tmp.id = table["id"].intValue
                tmp.title = table["title"].stringValue
                return tmp
            })
            
            self.users = json["users"].arrayValue.map({ (user) in
                var tmp = MinimumInfoUser()
                tmp.id = user["id"].intValue
                tmp.name = user["name"].stringValue
                return tmp
            })
            
            self.delegate?.initializeUI()
            
        }.catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.showMessage(title: title, msg: tmp_err.domain)
        }
    }
    
    func getTablesName() -> [String] {
        return tables.map({$0.title})
    }
    
    func getUsersName() -> [String] {
        return users.map({$0.name})
    }
    
    func getInitValue() -> String {
        if followUser.name.count != 0 {
            return followUser.name
        }
        
        return me.name
    }
    
    func export(formValue: [String:Any?]) {
        let tableTitle = formValue["table"] as! String
        let username = formValue["user"] as! String
        let allDay = formValue["allday"] as! Bool
        let calendarTitle = formValue["calendar"] as! String
        let format = formValue["format"] as! String
        
        let tableID = tables.filter({$0.title == tableTitle}).first!.id
        let userID = users.filter({$0.name == username}).first!.id
        let calendarID = calendar.filter({$0.title == calendarTitle}).first!.id
        
        api.getExportShiftData(userID: userID, tableID: tableID).done { (json) in
            self.addEvent(json: json["results"], allDay: allDay, id: calendarID, format: format)
        }.catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.showMessage(title: title, msg: tmp_err.domain)
        }
    }
}


// MARK: - カレンダー
extension ExportViewModel {
    func setCalendars() {
        calendar = eventStore.calendars(for: .event).map({
            var tmp = UserCalendar()
            tmp.id = $0.calendarIdentifier
            tmp.title = $0.title
            return tmp
        })
    }
    
    func getCalendarsTitle() -> [String] {
        return calendar.map({$0.title})
    }
    
    func addEvent(json: JSON, allDay: Bool, id: String, format: String) {
        let calendar = eventStore.calendar(withIdentifier: id)
        var isError = false
        var events:[EKEvent] = []
        
        for shift in json.arrayValue {
            let event = EKEvent(eventStore: eventStore)
            
            switch self.format.firstIndex(of: format)! {
            case 0:
                event.title = "\(shift["user"].stringValue) \(shift["shift"].stringValue)"
            case 1:
                event.title = "\(shift["shift"].stringValue)"
            default:
                event.title = "\(shift["user"].stringValue) \(shift["shift"].stringValue)"
            }
            
            event.calendar = calendar
            
            var tmpStart = ""
            var tmpEnd = ""
            let tmpDate = shift["date"].stringValue
            if shift["start"].stringValue.count == 0 || shift["end"].stringValue.count == 0 || allDay {
                tmpStart = "12:00:00"
                tmpEnd = "12:00:00"
                event.isAllDay = true
            }else {
                tmpStart = shift["start"].stringValue
                tmpEnd = shift["end"].stringValue
                event.isAllDay = false
            }
            
            let start = getFormatterDateFromString(format: "yyyy-MM-dd HH:mm:ss", dateString: tmpDate+" "+tmpStart)
            var end = getFormatterDateFromString(format: "yyyy-MM-dd HH:mm:ss", dateString: tmpDate+" "+tmpEnd)
            
            if start > end && !event.isAllDay {
                let calendarCurrent = Calendar.current
                var components = calendarCurrent.dateComponents([.year, .month, .day], from: end)
                components.setValue(0, for: Calendar.Component.year)
                components.setValue(0, for: Calendar.Component.month)
                components.setValue(1, for: Calendar.Component.day)
                end = calendarCurrent.date(byAdding: components, to: end)!
            }
            
            event.startDate = start
            event.endDate = end
            events.append(event)
            
            do {
                try eventStore.save(event, span: .thisEvent)
            } catch let error {
                print(error)
                isError = true
                
                for event in events {
                    do {
                        try eventStore.remove(event, span: .thisEvent)
                    } catch let error {
                        print(error)
                    }
                }
                
                break
            }
        }
        
        if isError {
            self.delegate?.showMessage(title: "エラー", msg: "カレンダーへ追加中にエラーが発生しました")
        }else {
            self.delegate?.showMessage(title: "成功", msg: "エクスポートが完了しました")
        }
    }
    
    func allowAuthorization() {
        if getAuthorization_status() {
            return
        } else {
            eventStore.requestAccess(to: .event, completion: {
                (granted, error) in
                if granted {
                    return
                }
                else {
                    print("Not allowed")
                }
            })
        }
    }
    
    func getAuthorization_status() -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch status {
        case .notDetermined:
            print("NotDetermined")
            return false
            
        case .denied:
            print("Denied")
            return false
            
        case .authorized:
            print("Authorized")
            return true
            
        case .restricted:
            print("Restricted")
            return false
            
        default:
            return false
        }
    }
}
