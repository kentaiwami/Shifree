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


protocol CalendarViewInterface: class {
    var start: String { get set }
    var end: String { get set }
    var currentDate: String { get set }
    var targetDate: String { get set }
    
    func initializeUI()
    func showErrorAlert(title: String, msg: String)
    func updateTableViewData()
}

class CalendarViewController: UIViewController, CalendarViewInterface {
    var start: String = ""
    var end: String = ""
    var currentDate: String = ""
    var targetDate: String = ""
    
    fileprivate var presenter: CalendarViewPresenter!
    fileprivate weak var calendar: FSCalendar!
    fileprivate var tableView: UITableView!
    fileprivate var heightConst: Constraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        presenter.login()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.title = "Calendar"
        initializeNavigationItem()
        
        // 起動時は実行せず、他画面から戻ってきた時に再取得&表示内容の更新
        if calendar != nil && tableView != nil {
            getUserShift()
        }
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
        view.addSubview(calendar)
        self.calendar = calendar
        
        self.calendar.top(to: self.view)
        self.calendar.left(to: self.view)
        self.calendar.right(to: self.view)
        heightConst = self.calendar.height(self.view.frame.height/2)
        
        currentDate = GetFormatterDateString(format: "yyyy-MM-dd", date: self.calendar.today!)
        presenter.setTableViewShift()
    }
    
    fileprivate func initializeTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.view.addSubview(tableView)
        
        tableView.topToBottom(of: self.calendar)
        tableView.left(to: self.view)
        tableView.right(to: self.view)
        tableView.bottom(to: self.view)
        
        tableView.backgroundView = GetEmptyView(msg: EmptyMessage.noShiftInfo.rawValue)
    }
    
    private func initializeNavigationItem() {
        let check = UIBarButtonItem(image: UIImage(named: "switch_calendar"), style: .plain, target: self, action: #selector(TapChangeCalendarButton))
        let info = UIBarButtonItem(image: UIImage(named: "information"), style: .plain, target: self, action: #selector(TapColorInformationButton))

        self.tabBarController?.navigationItem.setRightBarButton(check, animated: true)
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


// MARK: - Presenterとのやり取りで使用
extension CalendarViewController {
    func initializeUI() {
        initializeCalendarView()
        initializeTableView()
    }
    
    func updateTableViewData() {
        presenter.setTableViewShift()
        self.tableView.reloadData()
        self.calendar.reloadData()
        
        if presenter.getTableViewShift().count == 0 {
            tableView.backgroundView?.isHidden = false
        }else {
            tableView.backgroundView?.isHidden = true
        }
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self, completion: nil)
    }
}

// MARK: - CalendarDetailViewからアクセスして、変数を取り出すための関数一覧
extension CalendarViewController {
    func getTableViewShift() -> [TableViewShift] {
        return presenter.getTableViewShift()
    }
    
    func getMemo() -> String {
        return presenter.getMemo()
    }
    
    func getTargetUserShift() -> TargetUserShift {
        return presenter.getTargetUserShift()
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
        targetDate = GetFormatterDateString(format: "yyyy-MM-dd", date: date)
        
        if presenter.userColorScheme.count == 0 {
            return nil
        }else {
            return [UIColor.hex(presenter.userColorScheme, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = GetFormatterDateString(format: "yyyy-MM-dd", date: date)
        updateTableViewData()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        targetDate = GetFormatterDateString(format: "yyyy-MM-dd", date: date)
        
        if presenter.userColorScheme.count == 0 {
            return nil
        }else {
            return [UIColor.hex(presenter.userColorScheme, alpha: 1.0)]
        }
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        targetDate = GetFormatterDateString(format: "yyyy-MM-dd", date: date)
        return presenter.eventNumber
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        getUserShift()
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.clear
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        return UIColor.black
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        return UIColor.hex(Color.main.rawValue, alpha: 1.0)
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
        
        let detailVC = CalendarDetailViewController()
        detailVC.setIndexPath(at: indexPath)
        self.navigationController!.pushViewController(detailVC, animated: true)
    }
}
