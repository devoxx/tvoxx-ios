//
//  TalkCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 25/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import AlamofireImage

class TalkCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailView:UIImageView!
    @IBOutlet weak var titleLabel:UILabel!
    
    func configureCellWithTalk(talk:Talk) {
        self.titleLabel.text = talk.title
        self.thumbnailView.af_setImageWithURL(NSURL(string:talk.thumbnailUrl)!, placeholderImage: nil)
    }
}
