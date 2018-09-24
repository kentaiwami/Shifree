//
//  ColorSchemViewModel.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/01.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import Foundation

protocol ColorSchemViewModelDelegate: class {
    func successGetShiftCategory()
    func successUpdateShiftCategory()
    func faildAPI(title: String, msg: String)
}

class ColorSchemViewModel {
    weak var delegate: ColorSchemViewModelDelegate?
    private let api = API()
    private(set) var shiftCategoryColors: [ShiftCategoryColor] = []
    
    func setOriginShiftCategoryColor() {
        shiftCategoryColors = []
        
        api.getShiftCategoryColor().done { (json) in
            json["results"].arrayValue.forEach({ (shiftCategoryColor) in
                var tmp = ShiftCategoryColor()
                tmp.name = shiftCategoryColor["category_name"].stringValue
                tmp.color = shiftCategoryColor["hex"].stringValue
                tmp.categoryId = shiftCategoryColor["category_id"].intValue
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
    
    func setShiftCategoryColor(color: String, indexPath: IndexPath) {
        shiftCategoryColors[indexPath.row].color = color
        self.delegate?.successGetShiftCategory()
    }
    
    func updateShiftCategoryColor() {
        var schemes:[[String:Any]] = []
        
        shiftCategoryColors.filter({$0.color != ""}).forEach { (shiftCategoryColor) in
            schemes.append(["category_id": shiftCategoryColor.categoryId, "hex": shiftCategoryColor.color])
        }
        
        api.updateShiftCategoryColor(schemes: schemes).done { (json) in
            self.delegate?.successUpdateShiftCategory()
        }
        .catch { (err) in
            let tmp_err = err as NSError
            let title = "Error(" + String(tmp_err.code) + ")"
            self.delegate?.faildAPI(title: title, msg: tmp_err.domain)
        }
    }
}
