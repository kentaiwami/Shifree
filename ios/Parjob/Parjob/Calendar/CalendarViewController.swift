//
//  CalendarViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit


protocol CalendarViewInterface: class {
    var start: String { get }
    var end: String { get }
    
    func initializeCalendar()
    func showErrorAlert(title: String, msg: String)
}

class CalendarViewController: UIViewController, CalendarViewInterface {

    private var presenter: CalendarViewPresenter!
    
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
        self.view.backgroundColor = UIColor.darkGray
    }
    
    func showErrorAlert(title: String, msg: String) {
        ShowStandardAlert(title: title, msg: msg, vc: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
