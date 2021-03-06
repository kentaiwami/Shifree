//
//  UserTopViewController.swift
//  Shifree
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
        initializeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.navigationItem.title = "ユーザ"
        self.tabBarController?.navigationItem.setLeftBarButton(nil, animated: true)
        self.tabBarController?.navigationItem.setRightBarButton(nil, animated: true)
        self.tabBarController?.delegate = self
        
        tableView.flashScrollIndicators()
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
        let salaryVC = SalaryViewController()
        let analyticsVC = AnalyticsViewController()
        let exportVC = ExportViewController()
        let colorSchemeVC = ColorSchemeViewController()
        let wageVC = WageViewController()
        let notificationVC = NotificationViewController()
        let userNameVC = UserNameViewController()
        let passwordVC = PasswordViewController()
        let followVC = FollowSettingViewController()
        let privacyPolicyVC = PrivacyPolicyViewController()
        let contactVC = ContactViewController()
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "給与"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return salaryVC}, onDismiss: {salaryVC in salaryVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "シフトの集計結果"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return analyticsVC}, onDismiss: {analyticsVC in analyticsVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "エクスポート"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return exportVC}, onDismiss: {exportVC in exportVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "カラー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return colorSchemeVC}, onDismiss: {colorSchemeVC in colorSchemeVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "時給"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return wageVC}, onDismiss: {wageVC in wageVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
            
            <<< ButtonRow() {
                $0.title = "通知"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return notificationVC}, onDismiss: {notificationVC in notificationVC.navigationController?.popViewController(animated: true)})
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
                $0.title = "フォロー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return followVC}, onDismiss: {followVC in followVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
            }
        
        form +++ Section("")
            <<< ButtonRow() {
                $0.title = "プライバシーポリシー"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return privacyPolicyVC}, onDismiss: {privacyPolicyVC in privacyPolicyVC.navigationController?.popViewController(animated: true)})
                $0.cell.textLabel?.numberOfLines = 0
        }
        
            <<< ButtonRow() {
                $0.title = "お問い合わせ"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback {return contactVC}, onDismiss: {contactVC in contactVC.navigationController?.popViewController(animated: true)})
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
        let popUp = PopupDialog(title: "再確認", message: "この端末に保存されている情報を削除し、サインアップ状態に戻します。\n既に登録されているシフト情報は削除されません。")
        let buttonReset = DestructiveButton(title: "リセット") {
            self.presenter.tapResetButton()
        }
        let buttonCancel = CancelButton(title: "Cancel"){}
        
        popUp.addButton(buttonReset)
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
