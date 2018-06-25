//
//  CalendarViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import FSCalendar


protocol CalendarViewInterface: class {
    var start: String { get }
    var end: String { get }
    
    func initializeCalendar()
    func showErrorAlert(title: String, msg: String)
}

class CalendarViewController: UIViewController, CalendarViewInterface, FSCalendarDelegate, FSCalendarDataSource {

    private var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    
    var start: String {
        return "20180611"
    }
    
    var end: String {
        return "20180611"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializePresenter()
        presenter.login()
    }
    
    func initializePresenter() {
        presenter = CalendarViewPresenter(view: self)
    }
    
    func initializeCalendar() {
        let hoge = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: hoge)
        print(result)
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        self.calendar = calendar
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
