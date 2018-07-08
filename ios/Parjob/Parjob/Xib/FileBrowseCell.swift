//
//  FileBrowseCell.swift
//  Parjob
//
//  Created by 岩見建汰 on 2018/07/07.
//  Copyright © 2018年 Kenta Iwami. All rights reserved.
//

import UIKit
import AlamofireImage

class FileBrowseCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbnailImageView.contentMode = .scaleAspectFit
        thumbnailImageView.top(to: self, offset: 5)
        thumbnailImageView.left(to: self, offset: 5)
        thumbnailImageView.right(to: self, offset: 5)
        thumbnailImageView.height(self.frame.height * 0.7)
        
        titleLabel.textAlignment = .center
        titleLabel.topToBottom(of: thumbnailImageView, offset: 10)
        titleLabel.left(to: self)
        titleLabel.right(to: self)
        titleLabel.sizeToFit()
    }
    
    func setAll(title: String, url: String) {
        titleLabel.text = title
        let encURL = URL(string: GetHost()+url.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        thumbnailImageView.af_setImage(withURL: encURL)
    }
}
