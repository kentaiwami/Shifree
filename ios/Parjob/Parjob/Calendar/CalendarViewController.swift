//
//  CalendarViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import FSCalendar
import TinyConstraints


protocol CalendarViewInterface: class {
    var start: String { get set }
    var end: String { get set }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
}

class CalendarViewController: UIViewController, CalendarViewInterface {
    var start: String = ""
    var end: String = ""
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    fileprivate var tableView: UITableView!
    fileprivate var heightConst: Constraint!
    
    //テーブルに表示するセル配列
//    var items: [String] = ["田中 店長 岩見 山岸 赤間"]
//    var sections: [String] = ["早番", "中番", "遅番", "その他", "休み"]
    var items: [String] = []
    var sections: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
    }
    
    func initializePresenter() {
        presenter = CalendarViewPresenter(view: self)
    }
    
    func initializeUI() {
        initializeCalendarView()
        initializeTableView()
        initializeNavigationItem()
    }
    
    func initializeCalendarView() {
        let calendar = FSCalendar()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scope = .week
        view.addSubview(calendar)
        self.calendar = calendar
        
        self.calendar.top(to: self.view)
        self.calendar.left(to: self.view)
        self.calendar.right(to: self.view)
        heightConst = self.calendar.height(self.view.frame.height/2)
    }
    
    func initializeTableView() {
        tableView = UITableView()
        tableView.delegate      =   self
        tableView.dataSource    =   self
        tableView.allowsSelection = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.topToBottom(of: self.calendar)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
    }
    
    func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "first"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
    }
    
    func TapChangeCalendarButton(sendor: UIButton) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        }else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        heightConst.constant = bounds.height
        self.view.layoutIfNeeded()
        
        setStartEndDate()
        presenter.getUserShift()
    }
    
    func setStartEndDate() {
        let startDate: Date
        let endDate: Date
        
        if self.calendar.scope == .week {
            startDate = self.calendar.currentPage
            endDate = self.calendar.gregorian.date(byAdding: .day, value: 6, to: startDate)!
        }else {
            let indexPath = self.calendar.calculator.indexPath(for: self.calendar.currentPage, scope: .month)
            startDate = self.calendar.calculator.monthHead(forSection: (indexPath?.section)!)
            endDate = self.calendar.gregorian.date(byAdding: .day, value: 41, to: startDate)!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        var result = formatter.string(from: startDate)
        start = result
        result = formatter.string(from: endDate)
        end = result
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        return [UIColor.brown, UIColor.blue, UIColor.red]
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(date)
        print(monthPosition)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let startDate: Date
        startDate = Date(timeInterval: 60*60*24, since: self.calendar.currentPage)
        if date == startDate {
            return 1
        }else {
            return 2
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setStartEndDate()
        presenter.getUserShift()
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.items[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
}
