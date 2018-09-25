//
//  ShiftViewModel.swift
//  Shifly
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation
import KeychainAccess

protocol ShiftViewModelDelegate: class {
    func initializeUI()
    func success()
    func faildAPI(title: String, msg: String)
}

class ShiftViewModel {
    weak var delegate: ShiftViewModelDelegate?
    private let api = API()
    private(set) var shiftDetail: [[ShiftDetail]] = []
    private(set) var shiftCategory: [ShiftCategory] = []
    
    func setShiftDetail() {
        shiftDetail = []
        shiftCategory = []
        
        api.getUserCompanyShiftNames().done { (json) in
            json["results"].arrayValue.forEach({ (category) in
                self.shiftCategory.append(ShiftCategory(id: category["category_id"].intValue, name: category["category_name"].stringValue))
                
                var tmpShiftDetails: [ShiftDetail] = []
                category["shifts"].arrayValue.forEach({ (shift) in
                    tmpShiftDetails.append(ShiftDetail(id: shift["id"].intValue, name: shift["name"].stringValue, start: shift["start"].stringValue, end: shift["end"].stringValue))
                })
                
                self.shiftDetail.append(tmpShiftDetails)
            })
            
            self.delegate?.initializeUI()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
    
    func updateShiftDetail(formValues: [[String]]) {
        var tmpShiftDetail: [[ShiftDetail]] = shiftDetail
        var adds: [[String:Any]] = []
        var updates: [[String:Any]] = []
        var deletes: [Int] = []
        
        for(i, rowValues) in formValues.enumerated() {
            for value in rowValues {
                let currentShiftCategory = shiftCategory[i]
                let currentShiftDetails = shiftDetail[i]
                
                // ["ID", "シフト名", "開始時間", "終了時間"]に分割
                let split = value.components(separatedBy: ",")
                
                if split.count != 4 {
                    continue
                }
                
                if Int(split[0]) == -1 {
                    adds.append(["category_id": currentShiftCategory.id, "name": split[1], "start": split[2], "end": split[3]])
                }else {
                    let searchShiftDetailResult = currentShiftDetails.filter({$0.id == Int(split[0])})
                    if searchShiftDetailResult[0].name != split[1] || searchShiftDetailResult[0].start != split[2] || searchShiftDetailResult[0].end != split[3] {
                        updates.append(["id": searchShiftDetailResult[0].id, "category_id": currentShiftCategory.id, "name": split[1], "start": split[2], "end": split[3]])
                    }
                    
                    let index = tmpShiftDetail[i].indices.filter({tmpShiftDetail[i][$0].id == Int(split[0])}).first!
                    tmpShiftDetail[i].remove(at: index.advanced(by: 0))
                }
            }
        }
        
        tmpShiftDetail.forEach { (shiftDetails) in
            shiftDetails.forEach({ (shiftDetail) in
                deletes.append(shiftDetail.id)
            })
        }

        api.updateShift(adds: adds, updates: updates, deletes: deletes).done { (json) in
            self.delegate?.success()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }

}
