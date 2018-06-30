//
//  PopUpColorModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol PopUpColorModelDelegate: class {
    func successGetShiftCategory()
    func faildAPI(title: String, msg: String)
}

struct ShiftCategoryColor {
    var name: String = ""
    var color: String = ""
}

class PopUpColorModel {
    weak var delegate: PopUpColorModelDelegate?
    private let api = API()
    private(set) var shiftCategoryColors: [ShiftCategoryColor] = []
    
    func setShiftCategoryColor() {
        api.getShiftCategory().done { (json) in
            json["results"].arrayValue.forEach({ (shiftCategoryColor) in
                var tmp = ShiftCategoryColor()
                tmp.name = shiftCategoryColor["category_name"].stringValue
                tmp.color = shiftCategoryColor["hex"].stringValue
                self.shiftCategoryColors.append(tmp)
            })
            
            self.delegate?.successGetShiftCategory()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}