//
//  ColorTableViewCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/05.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import Foundation

class ColorTableViewCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let height = view.frame.height
        view.frame.size = CGSize(width: height, height: height)
        view.layer.cornerRadius = view.frame.width / 2
    }
    
    var viewBackgroundColor = UIColor.clear

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if view.backgroundColor != UIColor.clear {
            viewBackgroundColor = self.view.backgroundColor!
        }
        
        if(selected) {
            self.view.backgroundColor = viewBackgroundColor
        }
    }
    
    func setCell(name: String, color: String) {
        label.text = name
        view.backgroundColor = UIColor.hex(color, alpha: 1.0)
    }
}
