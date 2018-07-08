//
//  Utility.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Eureka
import PopupDialog
import NVActivityIndicatorView
import TinyConstraints

func IsValidateFormValue(form: Form) -> Bool {
    var err_count = 0
    for row in form.allRows {
        if !row.isHidden {
            err_count += row.validate().count
        }
    }
    
    if err_count == 0 {
        return true
    }
    
    return false
}

func IsHTTPStatus(statusCode: Int?) -> Bool {
    // 200系以外ならエラー
    let code = String(statusCode!)
    var results:[String] = []
    
    if code.pregMatche(pattern: "2..", matches: &results) {
        return true
    }else {
        return false
    }
}

func ShowStandardAlert(title: String, msg: String, vc: UIViewController, completion: (() -> Void)?) {
    let button = DefaultButton(title: "OK", dismissOnTap: true) {}
    let popup = PopupDialog(title: title, message: msg) {
        if let tmpCompletion = completion {
            tmpCompletion()
        }
    }
    popup.transitionStyle = .zoomIn
    popup.addButtons([button])
    vc.present(popup, animated: true, completion: nil)
}

func GetFormatterDateString(format: String, date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    
    return formatter.string(from: date)
}

func GetWageTime() -> [String] {
    var wageTime: [String] = []
    
    for hour in 0...23 {
        for minute in [0, 30] {
            wageTime.append(String(format: "%02d", hour) + ":" + String(format: "%02d", minute))
        }
    }
    return wageTime
}

func GetMatchStrings(targetString: String, pattern: String) -> [String] {
    
    var matchStrings:[String] = []
    
    do {
        
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let targetStringRange = NSRange(location: 0, length: (targetString as NSString).length)
        
        let matches = regex.matches(in: targetString, options: [], range: targetStringRange)
        
        for match in matches {
            
            // rangeAtIndexに0を渡すとマッチ全体が、1以降を渡すと括弧でグループにした部分マッチが返される
            let range = match.rangeAt(0)
            let result = (targetString as NSString).substring(with: range)
            
            matchStrings.append(result)
        }
        
        return matchStrings
        
    } catch {
        print("error: getMatchStrings")
    }
    return []
}


class Indicator {
    let indicator = NVActivityIndicatorView(frame: CGRect.zero, type: .circleStrokeSpin, color: UIColor.lightGray)
    let wh: CGFloat = 50
    
    func start() {
        if let topController = UIApplication.topViewController() {
            topController.view.addSubview(indicator)
            indicator.center(in: topController.view)
            indicator.width(wh)
            indicator.height(wh)
            indicator.startAnimating()
        }
    }
    
    func stop() {
        indicator.stopAnimating()
    }
}

