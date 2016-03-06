//
//  SpeakerCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 06/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import AlamofireImage

class SpeakerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var avatarView:UIImageView!
    @IBOutlet weak var nameLabel:UILabel!
    
    var speaker:SpeakerListItem? {
        didSet {
            if let speaker = speaker {
                nameLabel.text = "\(speaker.firstName.capitalizedString) \(speaker.lastName.capitalizedString)"
                if let avatarUrl = speaker.avatarUrl {
                    avatarView.af_setImageWithURL(NSURL(string:avatarUrl)!)
                } else {
                    avatarView.image = UIImage(named: "speaker")
                }
            } else {
                avatarView.image = UIImage(named: "speaker")
                nameLabel.text = ""
            }
        }
    }
    
}
