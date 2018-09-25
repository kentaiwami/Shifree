//
//  AddShiftViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/06/23.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol AddShiftViewModelDelegate: class {
    func successAdd()
    func initializeUI()
    func faildAPI(title: String, msg: String)
}

class AddShiftViewModel {
    weak var delegate: AddShiftViewModelDelegate?
    private let api = API()
    private(set) var shiftCategoryList:[ShiftCategory] = []
    private(set) var unRegisteredShift:[String] = []
    
    func getShiftCategory() {
        api.getShiftCategory().done { (json) in
            json["results"].arrayValue.forEach({ (shiftCategoryJson) in
                self.shiftCategoryList.append(ShiftCategory(id: shiftCategoryJson["category_id"].intValue, name: shiftCategoryJson["category_name"].stringValue))
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func setUnRegisteredShift(unRegisteredShift:[String]) {
        self.unRegisteredShift = unRegisteredShift
    }
    
    func AddShift(formValues:[[String]]) {
        var adds:[[String:Any]] = []
        
        // 見た目を整えるために、メッセージ表示用のセクションを追加しているためfilterで配列の長さが0を除外
        for sectionValue in formValues.filter({$0.count != 0}) {
            // [0]:シフト名, [1]:カテゴリ名, [2]:開始時間, [3]:終了時間
            let categoryResult = shiftCategoryList.filter({$0.name == sectionValue[1]})
            if categoryResult.count == 0 {
                continue
            }
            
            adds.append(["category_id": categoryResult[0].id, "start": sectionValue[2], "end": sectionValue[3], "name": sectionValue[0]])
        }
        
        if adds.count == 0 {
            self.delegate?.faildAPI(title: "エラー", msg: "新規追加するシフトがありませんでした")
        }else {
            api.updateShift(adds: adds, updates: [], deletes: []).done { (json) in
                self.delegate?.successAdd()
            }
            .catch { (err) in
                let tmp_err = err as NSError
                let title = "Error(" + String(tmp_err.code) + ")"
                self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
            }
        }
    }
}
