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
    var currentDate: String { get set }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func updateTableViewData()
}

class CalendarViewController: UIViewController, CalendarViewInterface {
    var start: String = ""
    var end: String = ""
    var currentDate: String = ""
    
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    fileprivate var tableView: UITableView!
    fileprivate var heightConst: Constraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
    }
    
    private func initializePresenter() {
        presenter = CalendarViewPresenter(view: self)
    }
    
    func initializeUI() {
        initializeCalendarView()
        initializeTableView()
        initializeNavigationItem()
    }
    
    private func initializeCalendarView() {
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
        
        currentDate = GetFormatterDateString(format: "yyyy-MM-dd", date: self.calendar.today!)
        presenter.setUserShiftAndCategories()
    }
    
    private func initializeTableView() {
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
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "first"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
    }
    
    @objc private func TapChangeCalendarButton(sendor: UIButton) {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
        }else {
            self.calendar.setScope(.month, animated: true)
        }
    }
    
    fileprivate func getUserShift() {
        setStartEndDate()
        presenter.getUserShift()
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }
    
    private func setStartEndDate() {
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
        
        start = GetFormatterDateString(format: "yyyyMMdd", date: startDate)
        end = GetFormatterDateString(format: "yyyyMMdd", date: endDate)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        heightConst.constant = bounds.height
        self.view.layoutIfNeeded()
        
        getUserShift()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        //TODO: ユーザが設定したカラースキームを適用する
        return [UIColor.blue]
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = GetFormatterDateString(format: "yyyy-MM-dd", date: date)
        updateTableViewData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        //TODO: nullだったら0を返し、何かしらのシフトが入っていたら1を返す
//        let startDate: Date
//        startDate = Date(timeInterval: 60*60*24, since: self.calendar.currentPage)
        return 1
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        getUserShift()
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    
    func updateTableViewData() {
        presenter.setUserShiftAndCategories()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = presenter.userShifts[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.shiftCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.shiftCategories[section]
    }
}
