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
import PopupDialog
import UserNotifications


protocol CalendarViewInterface: class {
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func updateView()
}

class CalendarViewController: UIViewController, CalendarViewInterface {
//    var currentDate: Date = Date()
//    var targetDate: Date = Date()
    
//    var start: Date = Date()
//    var end: Date = Date()
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    fileprivate var heightConst: Constraint!
    fileprivate var todayColor: UIColor!
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var tableViews: [UITableView] = []
    fileprivate var scrollView: UIScrollView!
    fileprivate var tableCount = 9
    fileprivate var currentScrollPage = 0
    
    // 通知を受信してカレンダーのページを更新した場合とスワイプ操作で更新した場合で、日付操作をスキップするために使用
    fileprivate var isReceiveNotificationSetCurrentPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "カレンダー"
        initializeNavigationItem()
        
        // 起動時は実行せず、他画面から戻ってきた時に再取得&表示内容の更新
        if calendar != nil {
            getUserShift()
        }
    }
    
    fileprivate func getUserShift() {
        setStartEndDate()
        presenter.getAllUserShift()
    }
    
    fileprivate func setStartEndDate() {
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
        
        presenter.setStartEndDate(start: startDate, end: endDate)
    }
    
    fileprivate func updateCalendarSelectedDate(newSelectDate: Date) {
//        calendar.select(newSelectDate)
//        self.currentDate = newSelectDate
//        presenter.setCurrentPage(currentPage: calendar.currentPage)
//
//        let position = presenter.getSelectedPosition(target: newSelectDate) + 1
//        setUpScrollPosition(page: position)
    }
    
    fileprivate func setUpTodayColor(didSelectedDate: Date) {
        let calendarCurrent = Calendar.current
        
        if calendarCurrent.isDate(didSelectedDate, inSameDayAs: Date()) {
            calendar.appearance.todayColor = todayColor
            calendar.appearance.titleTodayColor = UIColor.clear
        }else {
            calendar.appearance.todayColor = UIColor.clear
            calendar.appearance.titleTodayColor = todayColor
        }
    }
    
    fileprivate func setUpScrollPosition(page: Int) {
        let width = self.view.frame.width * CGFloat(page)
        scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        currentScrollPage = page + 1
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



// MARK: - Initialize
extension CalendarViewController {
    fileprivate func initializePresenter() {
        presenter = CalendarViewPresenter(view: self)
    }
    
    fileprivate func initializeUserNotificationCenter() {
        UNUserNotificationCenter.current().requestAuthorization(
        options: [.badge, .alert, .sound]) {(accepted, error) in
            if accepted {
                print("Notification access accepted !")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            else{
                print("Notification access denied.")
            }
        }
    }
    
    fileprivate func initializeCalendarView() {
        let calendar = FSCalendar()
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scope = .week
        calendar.appearance.weekdayTextColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        calendar.appearance.headerTitleColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        calendar.appearance.headerDateFormat = "yyyy年MM月"
        todayColor = calendar.appearance.todayColor
        
        presenter.initCurrentDate()
        calendar.select(presenter.getCurrentAndPageDate().currentDate)
        presenter.setCurrentPage(currentPage: calendar.currentPage)
        presenter.setTableViewShift()
        
        view.addSubview(calendar)
        self.calendar = calendar
        
        self.calendar.top(to: self.view)
        self.calendar.left(to: self.view)
        self.calendar.right(to: self.view)
        heightConst = self.calendar.height(self.view.frame.height/2)
        
        // view追加後でないとscopeがnilになるためここでセット
        setStartEndDate()
    }
    
    fileprivate func initializeTableView() {
        var tableViewX: CGFloat = 0
        
        for i in 0..<tableCount {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tag = i
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.frame = CGRect(x: tableViewX, y: calendar.frame.height, width: self.view.frame.width, height: self.view.frame.height - calendar.frame.height)
            scrollView.addSubview(tableView)
            tableView.backgroundView = getEmptyView(msg: EmptyMessage.noShiftInfo.rawValue)
            tableViews.append(tableView)
            
            tableViewX = tableView.frame.origin.x + tableView.frame.width
        }
    }
    
    fileprivate func initializeScrollView() {
        let width = self.view.frame.width * CGFloat(tableCount)
        scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: width, height: 0)
        scrollView.alwaysBounceHorizontal = true
        scrollView.isPagingEnabled = true
        self.view.addSubview(scrollView)
        
        scrollView.topToBottom(of: calendar)
        scrollView.left(to: self.view)
        scrollView.right(to: self.view)
        scrollView.bottom(to: self.view)
        
        let position = presenter.getSelectedPosition(target: calendar.selectedDate!) + 1
        setUpScrollPosition(page: position)
    }
    
    fileprivate func initializeNavigationItem() {
        let month = UIBarButtonItem(image: UIImage(named: "month"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let info = UIBarButtonItem(image: UIImage(named: "information"), style: .plain, target: self, action: #selector(TapColorInformationButton))
        
        self.tabBarController?.navigationItem.setRightBarButton(month, animated: true)
        self.tabBarController?.navigationItem.setLeftBarButton(info, animated: true)
    }
}



// MARK: - NavigationItemTap
extension CalendarViewController {
    @objc fileprivate func TapColorInformationButton(sendor: UIButton) {
        let vc = PopUpColorViewController()
        let popUp = PopupDialog(viewController: vc)
        let buttonOK = DefaultButton(title: "OK"){}
        
        popUp.addButton(buttonOK)
        
        present(popUp, animated: true, completion: nil)
    }
    
    @objc fileprivate func TapChangeCalendarButton(sendor: UIButton) {
        let month = UIBarButtonItem(image: UIImage(named: "month"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let week = UIBarButtonItem(image: UIImage(named: "week"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: true)
            self.tabBarController?.navigationItem.setRightBarButton(month, animated: true)
        }else {
            self.calendar.setScope(.month, animated: true)
            self.tabBarController?.navigationItem.setRightBarButton(week, animated: true)
        }
    }
}


// MARK: - Presenterとのやり取りで使用
extension CalendarViewController {
    
    /// Login後に呼び出されてUIの初期化を実行
    func initializeUI() {
        initializeCalendarView()
//        initializeScrollView()
//        initializeTableView()
        initializeUserNotificationCenter()
    }
    
    func updateView() {
        presenter.setTableViewShift()
        
        self.calendar.reloadData()
        
        tableViews.forEach { (table) in
            table.reloadData()
            
            if presenter.getTableViewShift(tag: table.tag).count == 0 {
                table.backgroundView?.isHidden = false
            }else {
                table.backgroundView?.isHidden = true
            }
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}



// MARK: - FSCalendarDelegateAppearance（カレンダーのUI表示に関するデリゲート）
extension CalendarViewController: FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        let colorHex = presenter.getUserColorSchemeForCalendar(date: date)
        
        if colorHex.count == 0 {
            return nil
        }else {
            return [UIColor.hex(colorHex, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let colorHex = presenter.getUserColorSchemeForCalendar(date: date)
        
        if colorHex.count == 0 {
            return nil
        }else {
            return [UIColor.hex(colorHex, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return presenter.getEventNumber(date: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        if presenter.isTargetDateToday(targetDate: date) {
            return todayColor
        }else {
            return UIColor.hex(Color.main.rawValue, alpha: 1.0)
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
}


// MARK: - FSCalendarDelegate, FSCalendarDataSource（カレンダーに対するユーザ操作受付に関するデリゲート）
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        print("************** boundingRectWillChange **************")
        //        heightConst.constant = bounds.height
        //        self.view.layoutIfNeeded()
        //
        //        getAllUserShift()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("************** didSelect **************")
        
        //        setUpTodayColor(didSelectedDate: date)
        //
        //        currentDate = date
        //
        //        let position = presenter.getSelectedPosition(start: start, target: calendar.selectedDate!) + 1
        //        setUpScrollPosition(page: position)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("************** calendarCurrentPageDidChange **************")
        //        /*
        //         表示モードがWeekなら翌・先週を選択状態に
        //         Monthなら翌・先月の1日を選択状態に（ただし、今日が含まれる月表示の場合は「今日」）
        //         //TODO: スワイプでチェンジした時は日付操作をしない
        //         */
        //        print("***********************************")
        //        print("calendarCurrentPageDidChange")
        //        print("***********************************")
        //
        //
        //
        //        if !isReceiveNotificationSetCurrentPage {
        //            var isWeek = true
        //            if calendar.scope == .month {
        //                isWeek = false
        //            }
        //
        //            // カレンダーの選択状態を更新
        //            let newSelectDate = presenter.getShouldSelectDate(currentPage: calendar.currentPage, selectingDate: currentDate, isWeek: isWeek)
        //
        //            updateCalendarSelectedDate(newSelectDate: newSelectDate)
        //            setUpTodayColor(didSelectedDate: newSelectDate)
        //        }
        //        setStartEndDate()
        //        print(calendar.selectedDate)
        //        print(start)
        //        setUpScrollPosition(page: presenter.getSelectedPosition(start: start, target: calendar.selectedDate!) + 1)
        //
        //        isReceiveNotificationSetCurrentPage = false
        //        getAllUserShift()
    }
}



// MARK: - UIScrollViewDelegate
extension CalendarViewController: UIScrollViewDelegate {
    func changeSelectedDateByScroll(scrollViewCurrentPage: Int) {
        //        let calendarCurrent = Calendar.current
        //
        //        if scrollViewCurrentPage < currentScrollPage {
        //            let newSelectDate = calendarCurrent.date(byAdding: .day, value: -1, to: calendarCurrent.startOfDay(for: currentDate))!
        //            calendar.select(newSelectDate)
        //            self.currentDate = newSelectDate
        //            setUpTodayColor(didSelectedDate: newSelectDate)
        //        }else if scrollViewCurrentPage > currentScrollPage {
        //            let newSelectDate = calendarCurrent.date(byAdding: .day, value: 1, to: calendarCurrent.startOfDay(for: currentDate))!
        //            calendar.select(newSelectDate)
        //            self.currentDate = newSelectDate
        //            setUpTodayColor(didSelectedDate: newSelectDate)
        //        }
        //
        //        currentScrollPage = scrollView.currentPage
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //        if !decelerate {
        //            changeSelectedDateByScroll(scrollViewCurrentPage: scrollView.currentPage)
        //            isReceiveNotificationSetCurrentPage = true
        //        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //        changeSelectedDateByScroll(scrollViewCurrentPage: scrollView.currentPage)
        //        isReceiveNotificationSetCurrentPage = true
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //        cell.textLabel?.text = presenter.getTableViewShift(tag: tableView.tag)[indexPath.section].joined
        //        cell.textLabel?.numberOfLines = 0
        //        cell.textLabel?.lineBreakMode = .byWordWrapping
        //        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
        //        return presenter.getShiftCategories(start: start, tag: tableView.tag).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
        //        return presenter.getShiftCategories(start: start, tag: tableView.tag)[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        //        targetDate = currentDate
        //        let headerTitle = view as? UITableViewHeaderFooterView
        //        var bgColor = UIColor.clear
        //        var txtColor = UIColor.black
        //        let colorHex = presenter.getUserColorSchemeForTable(start: start, tag: tableView.tag)
        //
        //        if colorHex.count != 0 {
        //            if section == presenter.getUserSection(start: start, tag: tableView.tag) {
        //                bgColor = UIColor.hex(colorHex, alpha: 0.9)
        //                txtColor = UIColor.white
        //            }else {
        //                bgColor = UIColor.clear
        //                txtColor = UIColor.black
        //            }
        //        }
        //
        //        headerTitle?.contentView.backgroundColor = bgColor
        //        headerTitle?.textLabel?.textColor = txtColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        //
        //        let selectedShiftCategoryName = presenter.getShiftCategories(start: start, tag: tableView.tag)[indexPath.section]
        //        let detailVC = CalendarDetailViewController()
        //        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        //        detailVC.setSelectedData(memo: presenter.getMemo(), title: currentDateStr + " " + selectedShiftCategoryName, indexPath: indexPath, tableViewShifts: presenter.getTableViewShift(tag: tableView.tag), targetUserShift: presenter.getTargetUserShift())
        //        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}



// MARK: - Observer関連
extension CalendarViewController {
    fileprivate func addObservers() {
        notificationCenter.addObserver(self, selector: #selector(updateView(notification:)), name: .usershift, object: nil)
        
        let navigationController = self.navigationController
        let tabBarController = navigationController?.viewControllers.first as! UITabBarController
        let fileBrowseTopViewController = tabBarController.viewControllers![2] as! FileBrowseTopViewController
        
        // FileBrowseTopViewControllerのviewDidLoad内にあるaddObserverを実行
        fileBrowseTopViewController.loadViewIfNeeded()
    }
    
    @objc private func updateView(notification: Notification) {
        guard let dateDict = notification.object as? [String:Date] else {return}
        isReceiveNotificationSetCurrentPage = true
        self.calendar.currentPage = dateDict["sunday"]!
        updateCalendarSelectedDate(newSelectDate: dateDict["updated"]!)
        setUpTodayColor(didSelectedDate: dateDict["updated"]!)
        getUserShift()
        
        dismissViews(targetViewController: self, selectedIndex: 0)
        
        isReceiveNotificationSetCurrentPage = false
    }
}
