//
//  CalendarViewController.swift
//  Shifree
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
    
    // カレンダーの高さに関する制約を保存
    fileprivate var heightConst: Constraint!
    
    // ライブラリに設定されているデフォルトのカラーを保存
    fileprivate var todayColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "カレンダー"
        self.tabBarController?.delegate = self
        
        initializeNavigationItem()
        
        // 起動時は実行せず、他画面から戻ってきた時に再取得&表示内容の更新
        if calendar != nil {
            setStartEndDate()
            presenter.getAllUserShift()
            
            scrollView.flashScrollIndicators()
        }
        
        tableViews.forEach { (tableView) in
            tableView.indexPathsForSelectedRows?.forEach({
                tableView.deselectRow(at: $0, animated: true)
            })
        }
    }
    
    fileprivate func setStartEndDate() {
        let startDate: Date
        let endDate: Date
        
        if self.calendar.scope == .week {
            let indexPath = self.calendar.calculator.indexPath(for: self.calendar.currentPage, scope: .week)
            startDate = self.calendar.calculator.week(forSection: (indexPath?.section)!)
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
        
        // view追加後でないとnilになるためここでセット
        setStartEndDate()
        setUpTodayColor(didSelectedDate: presenter.getCurrentAndPageDate().currentDate)
    }
    
    fileprivate func initializeScrollView() {
        let width = self.view.frame.width * CGFloat(presenter.getTableCount())
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
        
        for i in 0..<presenter.getTableCount() {
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
        
        scrollView.flashScrollIndicators()
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
        let isFollowing = presenter.getIsFollowing()
        let prevFollowing = presenter.getPrevFollowing()
        
        self.tabBarController?.navigationItem.title = presenter.getTitle()
        
        // フォロー状態が変化したときだけアラート表示（初回起動時はprevFollowingがnilのため実行されない）
        if isFollowing != prevFollowing && prevFollowing != nil {
            var msg = "フォロー設定が無効化されたため、あなたのシフト情報が強調表示されます。"
            var isLeft = false
            if isFollowing {
                msg = "フォロー設定が有効化されたため、設定したユーザのシフト情報が強調表示されます。\n\n【注意事項】\n・フォローしているユーザのメモはプライバシー保護のため表示されません。\n・自身のメモは編集できません。編集する場合は、フォロー設定を無効化する必要があります。\n・強調表示の色は全て設定済みであればその設定に基づいて表示されますが、一部が設定されていない場合はフォローユーザの設定に基づいて表示されます。"
                isLeft = true
            }
            showStandardAlert(title: "フォロー状態が変更されました", msg: msg, vc: self, isLeft: isLeft)
        }
        
        presenter.setPrevFollowing(value: isFollowing)
        
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
        
        /*
         オブザーバー（アプリ起動状態で通知タップ）またはUserOption（通知からアプリ起動）でupdateViewが呼び出された際に、
         ユーザのセクションは変更されているため、テーブル更新後にセクションへの自動スクロールを行う
         */
        let updatedFromObserver = presenter.getUpdated()
        let updatedFromUserOption = MyApplication.shared.updated
        
        // 起動中に通知タップ
        if updatedFromObserver != nil {
            scrollTableViewToUserSection(date: updatedFromObserver!)
            
        // 通知タップでアプリ起動
        }else if updatedFromUserOption != nil {
            scrollTableViewToUserSection(date: updatedFromUserOption!)
            MyApplication.shared.updated = nil
            
        // 通常の画面更新
        }else {
            scrollScrollViewToPage(page: presenter.getScrollViewPosition(target: calendar.selectedDate!))
            scrollTableViewToUserSection(date: calendar.selectedDate!)
        }
        
        presenter.setUpdated(object: nil)
    }
    
    func showErrorAlert(title: String, msg: String) {
        showStandardAlert(title: title, msg: msg, vc: self)
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
        
        if !presenter.getIsFirstTime() {
            presenter.resetValues()
            tableViews.forEach { (table) in
                table.removeFromSuperview()
            }
            scrollView.removeFromSuperview()
            tableViews = []
            
            if calendar.scope == .week {
                presenter.setTableCount(isWeek: true)
            }else {
                presenter.setTableCount(isWeek: false)
            }
            
            setStartEndDate()
            presenter.setCurrentDate(date: calendar.selectedDate!)
            presenter.setCurrentPage(currentPage: calendar.currentPage)
            
            initializeScrollView()
            initializeTableView()
            
            presenter.getAllUserShift()
        }
        
        presenter.setIsFirstTime(value: false)
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
        
        if !presenter.getIsReceiveNotificationSetCurrentPage() {
            if presenter.getIsSwipe() {
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
                if !presenter.getIsTapedTabBar() {
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
        
        presenter.setIsSwipe(value: false)
        presenter.setIsReceiveNotificationSetCurrentPage(value: false)
        presenter.setIsTapedTabBar(value: false)
    }
}



// MARK: - UIScrollViewDelegate
extension CalendarViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if type(of: scrollView) == UIScrollView.self {
            presenter.setIsSwipe(value: true)
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
            presenter.setIsSwipe(value: false)
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
                bgColor = UIColor.hex(colorHex, alpha: 1.0)
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
        let selectedShiftCategoryName = presenter.getShiftCategories(tag: tableView.tag)[indexPath.section]
        let detailVC = CalendarDetailViewController()
        let currentDateStr = getFormatterStringFromDate(format: "yyyy-MM-dd", date: presenter.getCurrentAndPageDate().currentDate)
        detailVC.setSelectedData(
            memo: presenter.getMemo(),
            isFollowing: presenter.getIsFollowing(),
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
        if type(of: viewController) == CalendarViewController.self && type(of: viewController) == presenter.getPrevViewController() {
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
            
            if presenter.todayInDateRange() {
                setUpCalendarScrollTable()
            }else {
                presenter.setIsTapedTabBar(value: true)
                setUpCalendarScrollTable()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.presenter.getAllUserShift()
                }
            }
        }
        
        presenter.setPrevViewController(value: CalendarViewController.self)
    }
}



// MARK: - Observer関連
extension CalendarViewController {
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notification:)), name: .usershift, object: nil)
        
        let navigationController = self.navigationController
        let tabBarController = navigationController?.viewControllers.first as! UITabBarController
        let fileBrowseTopViewController = tabBarController.viewControllers![2] as! FileBrowseTopViewController
        
        // FileBrowseTopViewControllerのviewDidLoad内にあるaddObserverを実行
        fileBrowseTopViewController.loadViewIfNeeded()
    }
    
    @objc private func updateView(notification: Notification) {
        /*
         getAllUserShift()完了後のテーブル再読み込み時に、ユーザのセクションまでスクロールする必要があるため、日付を格納して通知からタップされた描画処理であることを伝える。
         */
        
        presenter.setIsReceiveNotificationSetCurrentPage(value: true)
        presenter.setUpdated(object: notification.object)
        
        let updated = presenter.getUpdated()
        
        calendar.select(updated!)
        presenter.setCurrentDate(date: updated!)
        presenter.setCurrentPage(currentPage: calendar.currentPage)
        setStartEndDate()
        
        scrollScrollViewToPage(page: presenter.getScrollViewPosition(target: updated!))
        setUpTodayColor(didSelectedDate: updated!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.presenter.getAllUserShift()
        }
        
        dismissViews(targetViewController: self, selectedIndex: 0)
        
        presenter.setIsReceiveNotificationSetCurrentPage(value: false)
    }
}
