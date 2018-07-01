//
//  UserTopViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka


protocol UserTopViewInterface: class {
//    func navigateCalendar()
}

class UserTopViewController: FormViewController, UserTopViewInterface {
    
    private var presenter: UserTopViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "User"
        self.tabBarController?.navigationItem.setLeftBarButton(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButton(nil, animated: true)
    }
    
    private func initializeAdminUserOnlyForm() {
        let userListVC = UserListViewController()
        let shiftCategoryVC = ShiftCategoryViewController()
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "ユーザリストの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userListVC}, onDismiss: {userListVC in userListVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "シフトカテゴリの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return shiftCategoryVC}, onDismiss: {shiftCategoryVC in shiftCategoryVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
    }
    
    private func initializeAnotherForm() {
        let wageVC = WageViewController()
        let userNameVC = UserNameViewController()
        let passwordVC = PasswordViewController()
        let colorSchemeVC = ColorSchemeViewController()
        let salaryVC = SalaryViewController()
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "時給の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return wageVC}, onDismiss: {wageVC in wageVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "ユーザ名の設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userNameVC}, onDismiss: {userNameVC in userNameVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "パスワードの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return passwordVC}, onDismiss: {passwordVC in passwordVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "カラースキームの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return colorSchemeVC}, onDismiss: {colorSchemeVC in colorSchemeVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "給与の閲覧"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return salaryVC}, onDismiss: {salaryVC in salaryVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
    }
    
    private func initializeUI() {
        LabelRow.defaultCellUpdate = { cell, row in
            cell.contentView.backgroundColor = .red
            cell.textLabel?.textColor = .white
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
            cell.textLabel?.textAlignment = .right
        }
        
        if presenter.isAdmin() {
            initializeAdminUserOnlyForm()
        }
        
        initializeAnotherForm()
    }
    
    private func initializePresenter() {
        presenter = UserTopViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
