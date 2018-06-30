//
//  CustomCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/30.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

class PopUpColorCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var shiftCategoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
