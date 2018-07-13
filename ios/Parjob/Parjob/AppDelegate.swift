//
//  AppDelegate.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import KeychainAccess
import PopupDialog
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("+++++++++++++++++++++++++++++++++++")
        print(url)
        print("+++++++++++++++++++++++++++++++++++")
        
        let keychain = Keychain()
        if let tmp = try! keychain.getString("role") {
            if tmp == "admin" {
                let shiftImportVC = ShiftImportViewController()
                shiftImportVC.setFilePath(path: url)
                let nav = UINavigationController()
                nav.viewControllers = [shiftImportVC]
                self.window!.rootViewController = nav
                self.window?.makeKeyAndVisible()
            }else {
                if let topController = UIApplication.topViewController() {
                    let button = DefaultButton(title: "OK", action: nil)
                    let popup = PopupDialog(title: "権限エラー", message: "シフトを取り込むことができません。")
                    popup.addButton(button)
                    topController.present(popup, animated: true, completion: nil)
                }
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().barTintColor = UIColor.hex(Color.main.rawValue, alpha: 1.0)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        let reset = GetResetFlag()
        let keychain = Keychain()
        
        if reset {
            try! keychain.removeAll()
        }
        
        if GetInsertDummyDataFlag() {
            let data = GetDummyData()
            try! keychain.set(data.userId, key: "userId")
            try! keychain.set(data.companyCode, key: "companyCode")
            try! keychain.set(data.userCode, key: "userCode")
            try! keychain.set(data.userName, key: "userName")
            try! keychain.set(data.password, key: "password")
            try! keychain.set(data.role, key: "role")
        }

        let key = try! keychain.getString("userId")

        if key == nil {
            let signupVC = SignUpViewController()
            let nav = UINavigationController()
            nav.viewControllers = [signupVC]
            self.window!.rootViewController = nav
            self.window?.makeKeyAndVisible()
        }

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        let manager = FileManager.default
        let inboxDir = manager.urls(for: .documentDirectory, in: .userDomainMask)[0].path + "/Inbox/"
        var fileNames: [String] {
            do {
                return try manager.contentsOfDirectory(atPath: inboxDir)
            }catch {
                return []
            }
        }
        
        for filename in fileNames {
            do {
                try manager.removeItem(atPath: inboxDir + filename)
            }catch {
                print("Remove Error File")
                print(filename)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var deviceToken = String(format: "%@", deviceToken as CVarArg) as String
        print("deviceToken = \(deviceToken)")
        
        let characterSet: CharacterSet = CharacterSet.init(charactersIn: "<>")
        deviceToken = deviceToken.trimmingCharacters(in: characterSet)
        deviceToken = deviceToken.replacingOccurrences(of: " ", with: "")
        
        let api = API()
        api.updateToken(token: deviceToken).done { (json) in
            print("SendToken = \(deviceToken)")
        }
        .catch { (err) in
            print(err)
        }
    }
}

