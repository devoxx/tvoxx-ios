//
//  SpeakerCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 29/11/2015.
//  Copyright © 2015 Epseelon. All rights reserved.
//

import UIKit
import AlamofireImage

class SpeakerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    
    func configureCellWithSpeaker(speaker:Speaker) {
        self.nameLabel.text = "\(speaker.firstName) \(speaker.lastName)"
        if let avatarUrl = speaker.avatarUrl, url = NSURL(string:avatarUrl) {
            self.avatarView.af_setImageWithURL(url, placeholderImage: nil)
        } else {
            self.avatarView.image = nil
        }
    }
}
