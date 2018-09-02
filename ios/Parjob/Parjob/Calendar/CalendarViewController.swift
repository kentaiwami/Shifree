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
    var currentDate: Date { get set }
    var targetDate: Date { get set }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func updateTableViewData()
}

class CalendarViewController: UIViewController, CalendarViewInterface {
    var currentDate: Date = Date()
    var targetDate: Date = Date()
    
    var start: Date = Date()
    var end: Date = Date()
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
//    fileprivate var tableView: UITableView!
    fileprivate var heightConst: Constraint!
    fileprivate var todayColor: UIColor!
    fileprivate let notificationCenter = NotificationCenter.default
    fileprivate var tableViews: [UITableView] = []
    fileprivate var scrollView: UIScrollView!
    
    // 通知を受信してカレンダーのページを更新した場合とスワイプ操作で更新した場合で、日付操作をスキップするために使用
    fileprivate var isReceiveNotificationSetCurrentPage = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
        addObservers()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "カレンダー"
        initializeNavigationItem()
        
        // 起動時は実行せず、他画面から戻ってきた時に再取得&表示内容の更新
        if calendar != nil {
            getUserShift()
        }
//        if calendar != nil && tableView != nil {
//            getUserShift()
//        }
    }
    
    private func initializePresenter() {
        presenter = CalendarViewPresenter(view: self)
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
        
        let currentAndPage = presenter.getCurrentAndPageDate()
        calendar.select(currentAndPage.currentDate)
        
        // 通知をタップして起動した場合はその値をカレンダーに設定する。
        // それ以外はcurrentDateのみDate()を設定し、currentPageはデフォルトのまま。
        if let page = currentAndPage.currentPage {
            calendar.currentPage = page
        }
        
        // どちらにスワイプしたかを把握するため、表示ページを更新
        presenter.setCurrentPage(currentPage: calendar.currentPage)
        
        view.addSubview(calendar)
        self.calendar = calendar
        
        self.calendar.top(to: self.view)
        self.calendar.left(to: self.view)
        self.calendar.right(to: self.view)
        heightConst = self.calendar.height(self.view.frame.height/2)
        
        currentDate = currentAndPage.currentDate
        presenter.setTableViewShift()
    }
    
    fileprivate func initializeTableView() {
        var tableViewX: CGFloat = 0
        
        for i in 0...8 {
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
        let width = self.view.frame.width * 9
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
    }
    
    private func initializeNavigationItem() {
        let month = UIBarButtonItem(image: UIImage(named: "month"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let info = UIBarButtonItem(image: UIImage(named: "information"), style: .plain, target: self, action: #selector(TapColorInformationButton))

        self.tabBarController?.navigationItem.setRightBarButton(month, animated: true)
        self.tabBarController?.navigationItem.setLeftBarButton(info, animated: true)
    }
    
    @objc private func TapColorInformationButton(sendor: UIButton) {
        let vc = PopUpColorViewController()
        let popUp = PopupDialog(viewController: vc)
        let buttonOK = DefaultButton(title: "OK"){}
        
        popUp.addButton(buttonOK)
        
        present(popUp, animated: true, completion: nil)
    }
    
    @objc private func TapChangeCalendarButton(sendor: UIButton) {
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
    
    fileprivate func getUserShift() {
        setStartEndDate()
        presenter.getUserShift(start: start, end: end)
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
        
        start = startDate
        end = endDate
    }
    
    fileprivate func updateCalendarSelectedDate(newSelectDate: Date) {
        calendar.select(newSelectDate)
        self.currentDate = newSelectDate
        presenter.setCurrentPage(currentPage: calendar.currentPage)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterとのやり取りで使用
extension CalendarViewController {
    func initializeUI() {
        initializeCalendarView()
//        initializeScrollView()
//        initializeTableView()
//        initializeUserNotificationCenter()
    }
    
    func updateTableViewData() {
        presenter.setTableViewShift()
        tableViews.forEach { (table) in
            table.reloadData()
        }
//        self.tableView.reloadData()
        self.calendar.reloadData()
        
        if presenter.getTableViewShift().count == 0 {
            tableViews.forEach { (table) in
                table.backgroundView?.isHidden = false
            }
//            tableView.backgroundView?.isHidden = false
        }else {
            tableViews.forEach { (table) in
                table.backgroundView?.isHidden = false
            }
//            tableView.backgroundView?.isHidden = true
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}


// MARK: - FSCalendar関連のデリゲート関数まとめ
extension CalendarViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        heightConst.constant = bounds.height
        self.view.layoutIfNeeded()
        
        getUserShift()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        targetDate = date
        
        if presenter.userColorScheme.count == 0 {
            return nil
        }else {
            return [UIColor.hex(presenter.userColorScheme, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        setUpTodayColor(didSelectedDate: date)
        
        currentDate = date
        updateTableViewData()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        targetDate = date
        
        if presenter.userColorScheme.count == 0 {
            return nil
        }else {
            return [UIColor.hex(presenter.userColorScheme, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        targetDate = date
        return presenter.eventNumber
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        /*
         表示モードがWeekなら翌・先週を選択状態に
         Monthなら翌・先月の1日を選択状態に（ただし、今日が含まれる月表示の場合は「今日」）
         */
        if !isReceiveNotificationSetCurrentPage {
            getUserShift()
            
//            let currentDate = currentDate
            var isWeek = true
            if calendar.scope == .month {
                isWeek = false
            }
            
            // カレンダーの選択状態を更新
            let newSelectDate = presenter.getShouldSelectDate(currentPage: calendar.currentPage, selectingDate: currentDate, isWeek: isWeek)
            
            updateCalendarSelectedDate(newSelectDate: newSelectDate)
            setUpTodayColor(didSelectedDate: newSelectDate)
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        
        let calendarCurrent = Calendar.current
        
        if calendarCurrent.isDate(date, inSameDayAs: Date()) {
            return todayColor
        }else {
            return UIColor.hex(Color.main.rawValue, alpha: 1.0)
        }
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
}


// MARK: - UITableView関連のデリゲート関数まとめ
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = presenter.getTableViewShift()[indexPath.section].joined
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.shiftCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return presenter.shiftCategories[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        targetDate = currentDate
        let headerTitle = view as? UITableViewHeaderFooterView
        var bgColor = UIColor.clear
        var txtColor = UIColor.black
        
        if presenter.userColorScheme.count != 0 {
            if section == presenter.userSection {
                bgColor = UIColor.hex(presenter.userColorScheme, alpha: 0.9)
                txtColor = UIColor.white
            }else {
                bgColor = UIColor.clear
                txtColor = UIColor.black
            }
        }
        
        headerTitle?.contentView.backgroundColor = bgColor
        headerTitle?.textLabel?.textColor = txtColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedShiftCategoryName = presenter.shiftCategories[indexPath.section]
        let detailVC = CalendarDetailViewController()
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: currentDate)
        detailVC.setSelectedData(memo: presenter.getMemo(), title: currentDateStr + " " + selectedShiftCategoryName, indexPath: indexPath, tableViewShifts: presenter.getTableViewShift(), targetUserShift: presenter.getTargetUserShift())
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}

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

extension CalendarViewController: UIScrollViewDelegate {
    
}
