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
        
        usernameLabel.top(to: self, offset: 5)
        usernameLabel.left(to: self, offset: 15)
        usernameLabel.font = UIFont.systemFont(ofSize: 16)
        usernameLabel.sizeToFit()
        
        createdLabel.bottom(to: self)
        createdLabel.right(to: self, offset: -30)
        createdLabel.font = UIFont.systemFont(ofSize: 15)
        createdLabel.textColor = UIColor.gray
        createdLabel.sizeToFit()
        
        commentTextLabel.left(to: self, offset: 15)
        commentTextLabel.topToBottom(of: usernameLabel, offset: 10)
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
