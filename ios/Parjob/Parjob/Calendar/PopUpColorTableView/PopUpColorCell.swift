//
//  CustomCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/06/30.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import TinyConstraints

class PopUpColorCell: UITableViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var shiftCategoryNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let height = colorView.frame.height
        colorView.frame.size = CGSize(width: height, height: height)
        colorView.layer.cornerRadius = colorView.frame.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCell(name: String, color: String) {
        shiftCategoryNameLabel.text = name
        colorView.backgroundColor = UIColor.hex(color, alpha: 1.0)
    }
}
