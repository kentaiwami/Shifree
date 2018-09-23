//
//  UserTopViewController.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Eureka
import PopupDialog


protocol UserTopViewInterface: class {
    func navigateSignUp()
}

class UserTopViewController: FormViewController, UserTopViewInterface {
    
    private var presenter: UserTopViewPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializePresenter()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "ユーザ"
        self.tabBarController?.navigationItem.setLeftBarButton(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButton(nil, animated: true)
        self.tabBarController?.delegate = self
        
        // 各設定画面から戻ってきた際、フォーム値を楽に更新するため再描画
        UIView.setAnimationsEnabled(false)
        self.form.removeAll()
       initializeUI()
        UIView.setAnimationsEnabled(true)
    }
    
    private func initializeAdminUserOnlyForm() {
        let userListSettingVC = UserListSettingViewController()
        let userListVC = UserListViewController()
        let shiftCategoryVC = ShiftCategoryViewController()
        let shiftVC = ShiftViewController()
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "ユーザリストの設定"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userListSettingVC}, onDismiss: {userListVC in userListVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
            <<< ButtonRow() {
                $0.title = "ユーザリストの閲覧"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userListVC}, onDismiss: {userListVC in userListVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "シフトカテゴリ"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return shiftCategoryVC}, onDismiss: {shiftCategoryVC in shiftCategoryVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
            <<< ButtonRow() {
                $0.title = "シフト"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return shiftVC}, onDismiss: {shiftVC in shiftVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
    }
    
    private func initializeAnotherForm() {
        let notificationVC = NotificationViewController()
        let wageVC = WageViewController()
        let userNameVC = UserNameViewController()
        let passwordVC = PasswordViewController()
        let colorSchemeVC = ColorSchemeViewController()
        let salaryVC = SalaryViewController()
        let followVC = FollowSettingViewController()
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "通知"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return notificationVC}, onDismiss: {notificationVC in notificationVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
            
            <<< ButtonRow() {
                $0.title = "時給"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return wageVC}, onDismiss: {wageVC in wageVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "ユーザ名"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return userNameVC}, onDismiss: {userNameVC in userNameVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "パスワード"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return passwordVC}, onDismiss: {passwordVC in passwordVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "カラー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return colorSchemeVC}, onDismiss: {colorSchemeVC in colorSchemeVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
            
            <<< ButtonRow() {
                $0.title = "給与"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return salaryVC}, onDismiss: {salaryVC in salaryVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "フォロー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return followVC}, onDismiss: {followVC in followVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
        form +++ Section("")
            <<< ButtonRow(){
                $0.title = "リセット"
                $0.baseCell.backgroundColor = UIColor.hex(Color.red.rawValue, alpha: 1.0)
                $0.baseCell.tintColor = UIColor.white
                }
                .onCellSelection {  cell, row in
                    self.ResetButtonTapped()
        }
    }
    
    private func initializeUI() {
        if presenter.isAdmin() {
            initializeAdminUserOnlyForm()
        }
        
        initializeAnotherForm()
    }
    
    private func ResetButtonTapped() {
        let popUp = PopupDialog(title: "再確認", message: "この端末に保存されている情報を削除し、Sign Up状態に戻します。\n既に登録されているシフト情報は削除されません。")
        let buttonOK = DefaultButton(title: "OK") {
            self.presenter.tapResetButton()
        }
        let buttonCancel = CancelButton(title: "Cancel"){}
        
        popUp.addButton(buttonOK)
        popUp.addButton(buttonCancel)
        present(popUp, animated: true, completion: nil)
    }
    
    private func initializePresenter() {
        presenter = UserTopViewPresenter(view: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


// MARK: - Presenterから呼び出される関数
extension UserTopViewController {
    func navigateSignUp() {
        let signupVC = SignUpViewController()
        signupVC.modalTransitionStyle = .crossDissolve
        let nav = UINavigationController()
        nav.viewControllers = [signupVC]
        self.present(nav, animated: true, completion: nil)
    }
}


extension UserTopViewController: UITabBarControllerDelegate {}
