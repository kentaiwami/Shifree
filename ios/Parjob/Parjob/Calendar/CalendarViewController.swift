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
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    fileprivate var tableViews: [UITableView] = []
    fileprivate var scrollView: UIScrollView!
    fileprivate let notificationCenter = NotificationCenter.default
    
    // カレンダーの高さに関する制約を保存
    fileprivate var heightConst: Constraint!
    
    // ライブラリに設定されているデフォルトのカラーを保存
    fileprivate var todayColor: UIColor!
    
    // 通知を受信してカレンダーのページを更新した場合とスワイプ操作で更新した場合で、日付操作をスキップするために使用。
    fileprivate var isReceiveNotificationSetCurrentPage = false
    
    // カレンダーのページが変化した際に、カレンダーをスワイプしたのか、テーブルをスワイプしたのか判定するためにしよう。
    fileprivate var isSwipe = false
    
    // タブバーがタップされた際の画面の型を保存
    fileprivate var prevViewController:Any.Type = CalendarViewController.self
    
    // 表示するテーブルの個数（1週間の7つと左右の2つで9つ使用。初期化時はWeekで表示しているため。）
    fileprivate var tableCount = 9
    fileprivate let weekCount = 9
    fileprivate let monthCount = 44
    
    // boundingRectWillChangeは初回起動時に実行させないため
    fileprivate var isFirstTime = true
    
    // タブバーをタップしてカレンダー操作をしたかどうか（ページ変更時のメソッドを発火させないため）
    fileprivate var isTapedTabBar = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
        addObservers()
        
        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "カレンダー"
        initializeNavigationItem()
        
        // 起動時は実行せず、他画面から戻ってきた時に再取得&表示内容の更新
        if calendar != nil {
            setStartEndDate()
            presenter.getAllUserShift()
        }
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
    
    fileprivate func scrollScrollViewToPage(page: Int) {
        let width = self.view.frame.width * CGFloat(page)
        scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        presenter.setCurrentScrollPage(page: page)
    }
    
    fileprivate func scrollTableViewToUserSection(date: Date) {
        let position = presenter.getTableViewScrollPosition(date: date)
        
        if tableViews[position.tableViewPosition].numberOfSections > 0 {
            tableViews[position.tableViewPosition].scrollToRow(at: position.scrollPosition, at: .top, animated: false)
        }
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
        
        // カレンダーの選択されている日付の位置にスクロール
        let position = presenter.getScrollViewPosition(target: calendar.selectedDate!)
        scrollScrollViewToPage(page: position)
    }
    
    fileprivate func initializeTableView() {
        view.layoutIfNeeded()
        
        var tableViewX: CGFloat = 0
        
        for i in 0..<tableCount {
            let tableView = UITableView()
            tableView.delegate = self
            tableView.dataSource = self
            tableView.tag = i
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
            tableView.frame = CGRect(x: tableViewX, y: 0, width: self.view.frame.width, height: scrollView.frame.height)
            scrollView.addSubview(tableView)
            tableView.backgroundView = getEmptyView(msg: EmptyMessage.noShiftInfo.rawValue)
            tableViews.append(tableView)
            
            tableViewX = tableView.frame.origin.x + tableView.frame.width
        }
    }
    
    fileprivate func initializeNavigationItem() {
        let month = UIBarButtonItem(image: UIImage(named: "month"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let week = UIBarButtonItem(image: UIImage(named: "week"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let info = UIBarButtonItem(image: UIImage(named: "information"), style: .plain, target: self, action: #selector(TapColorInformationButton))
        
        self.tabBarController?.navigationItem.setLeftBarButton(info, animated: true)
        
        // 初回起動時はnilのため、monthを設定。それ以外（画面表示時）はnilではないのでscopeに応じて設定。
        if self.calendar == nil {
            self.tabBarController?.navigationItem.setRightBarButton(month, animated: true)
        }else {
            if self.calendar.scope == .month {
                self.tabBarController?.navigationItem.setRightBarButton(week, animated: true)
            }else {
                self.tabBarController?.navigationItem.setRightBarButton(month, animated: true)
            }
        }
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
        initializeScrollView()
        initializeTableView()
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
        if presenter.isSameDate(targetDate1: date, targetDate2: Date()) {
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
        
        // 変化後のカレンダーの高さで制約を更新
        heightConst.constant = bounds.height
        self.view.layoutIfNeeded()
        
        if !isFirstTime {
            presenter.resetValues()
            tableViews.forEach { (table) in
                table.removeFromSuperview()
            }
            scrollView.removeFromSuperview()
            tableViews = []
            
            if calendar.scope == .week {
                tableCount = weekCount
            }else {
                tableCount = monthCount
            }
            
            setStartEndDate()
            presenter.setCurrentDate(date: calendar.selectedDate!)
            presenter.setCurrentPage(currentPage: calendar.currentPage)
            
            initializeScrollView()
            initializeTableView()
            
            presenter.getAllUserShift()
        }
        
        isFirstTime = false
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("************** didSelect **************")
        
        setUpTodayColor(didSelectedDate: date)
        presenter.setCurrentDate(date: date)
        scrollScrollViewToPage(page: presenter.getScrollViewPosition(target: date))
        
        scrollTableViewToUserSection(date: date)
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("************** calendarCurrentPageDidChange **************")
        
        if !isReceiveNotificationSetCurrentPage {
            if isSwipe {
                setStartEndDate()
                presenter.setCurrentDate(date: calendar.selectedDate!)
                presenter.setCurrentPage(currentPage: calendar.currentPage)
                
                let position = presenter.getScrollViewPosition(target: calendar.selectedDate!)
                scrollScrollViewToPage(page: position)
                
                // アニメーションと処理が被ってカクツクため、アニメーションが終わる頃まで少し遅延させる
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.presenter.getAllUserShift()
                }
                
            }else {
                /*
                 表示モードがWeekなら翌・先週を選択状態に
                 Monthなら翌・先月の1日を選択状態に（ただし、今日が含まれる月表示の場合は「今日」）
                 ただし、タブバーをタップして発火した場合は何もしない（ページがさらに変更されて日付操作されてしまうため）
                 */
                if !isTapedTabBar {
                    var isWeek = true
                    if calendar.scope == .month {
                        isWeek = false
                    }
                    let newSelectDate = presenter.getShouldSelectDate(currentPage: calendar.currentPage, isWeek: isWeek)
                    calendar.select(newSelectDate)
                    presenter.setCurrentDate(date: newSelectDate)
                    presenter.setCurrentPage(currentPage: calendar.currentPage)
                    setStartEndDate()
                    
                    let position = presenter.getScrollViewPosition(target: newSelectDate)
                    scrollScrollViewToPage(page: position)
                    setUpTodayColor(didSelectedDate: newSelectDate)
                    
                    // アニメーションと処理が被ってカクツクため、アニメーションが終わる頃まで少し遅延させる
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.presenter.getAllUserShift()
                    }
                }
            }
        }
        
        isSwipe = false
        isReceiveNotificationSetCurrentPage = false
        isTapedTabBar = false
    }
}



// MARK: - UIScrollViewDelegate
extension CalendarViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if type(of: scrollView) == UIScrollView.self {
            isSwipe = true
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if type(of: scrollView) == UIScrollView.self {
            let newSelectDateByScroll = presenter.getNewSelectDateByScroll(newScrollPage: scrollView.currentPage)
            let tmpSelectedDateByScrollPage = calendar.gregorian.date(byAdding: .day, value: scrollView.currentPage - 1, to: presenter.getStartEndDate().start)!
            var newSelectedDate = Date()
            
            // スクロール先のページとスクロールによって求めた日付が違った場合、一気にスクロールしたということなので、スクロールしたページ番号から日付を求めて設定する
            if presenter.isSameDate(targetDate1: newSelectDateByScroll, targetDate2: tmpSelectedDateByScrollPage) {
                newSelectedDate = newSelectDateByScroll
            }else {
                newSelectedDate = tmpSelectedDateByScrollPage
            }
            
            calendar.select(newSelectedDate)
            setUpTodayColor(didSelectedDate: newSelectedDate)
            
            presenter.setCurrentDate(date: newSelectedDate)
            presenter.setCurrentScrollPage(page: scrollView.currentPage)

            scrollTableViewToUserSection(date: newSelectedDate)
            isSwipe = false
        }
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = presenter.getTableViewShift(tag: tableView.tag)[indexPath.section].joined
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return presenter.getShiftCategories(tag: tableView.tag).count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let shiftCategories = presenter.getShiftCategories(tag: tableView.tag)
        
        if shiftCategories.count == 0 {
            return nil
        }else {
            return shiftCategories[section]
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerTitle = view as? UITableViewHeaderFooterView
        var bgColor = UIColor.clear
        var txtColor = UIColor.black
        let colorHex = presenter.getUserColorSchemeForTable(tag: tableView.tag)
        
        if colorHex.count != 0 {
            if section == presenter.getUserSection(tag: tableView.tag) {
                bgColor = UIColor.hex(colorHex, alpha: 0.9)
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
        
        let selectedShiftCategoryName = presenter.getShiftCategories(tag: tableView.tag)[indexPath.section]
        let detailVC = CalendarDetailViewController()
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: presenter.getCurrentAndPageDate().currentDate)
        detailVC.setSelectedData(
            memo: presenter.getMemo(),
            title: currentDateStr + " " + selectedShiftCategoryName,
            indexPath: indexPath,
            tableViewShifts: presenter.getTableViewShift(tag: tableView.tag),
            targetUserShift: presenter.getTargetUserShift()
        )
        
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}



// MARK: - UITabBarControllerDelegate
extension CalendarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if type(of: viewController) == CalendarViewController.self && type(of: viewController) == prevViewController {
            let startEnd = presenter.getStartEndDate()
            let setUpCalendarScrollTable = { () -> Void in
                self.calendar.select(Date())
                self.presenter.setCurrentDate(date: self.calendar.selectedDate!)
                self.presenter.setCurrentPage(currentPage: self.calendar.currentPage)
                self.setStartEndDate()
                self.scrollScrollViewToPage(page: self.presenter.getScrollViewPosition(target: Date()))
                self.scrollTableViewToUserSection(date: Date())
                self.setUpTodayColor(didSelectedDate: Date())
            }
            
            /*
            「今日」が範囲内にある場合は単純に日付等の操作のみ
             範囲外にある場合は、ページ変更のメソッドが発火するため、フラグを立ててから
            */
            
            if startEnd.start <= Date() && Date() <= startEnd.end {
                setUpCalendarScrollTable()
            }else {
                isTapedTabBar = true
                setUpCalendarScrollTable()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.presenter.getAllUserShift()
                }
            }
        }
        
        prevViewController = type(of: viewController)
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
        calendar.select(dateDict["updated"]!)
        presenter.setCurrentDate(date: dateDict["updated"]!)
        presenter.setCurrentPage(currentPage: calendar.currentPage)
        scrollScrollViewToPage(page: presenter.getScrollViewPosition(target: dateDict["updated"]!))
        
        setUpTodayColor(didSelectedDate: dateDict["updated"]!)
        setStartEndDate()
        presenter.getAllUserShift()
        
        dismissViews(targetViewController: self, selectedIndex: 0)
        
        isReceiveNotificationSetCurrentPage = false
    }
}
