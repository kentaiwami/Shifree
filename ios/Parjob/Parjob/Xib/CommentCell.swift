//
//  CommentCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/08.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var commentTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        usernameLabel.top(to: self)
        usernameLabel.left(to: self, offset: 15)
        usernameLabel.sizeToFit()
        
        createdLabel.top(to: self)
        createdLabel.right(to: self, offset: -15)
        createdLabel.sizeToFit()
        
        commentTextLabel.bottom(to: self)
        commentTextLabel.left(to: self, offset: 15)
        commentTextLabel.sizeToFit()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setAll(username: String, created: String, text: String) {
        usernameLabel.text = username
        createdLabel.text = created
        commentTextLabel.text = text
    }
}
