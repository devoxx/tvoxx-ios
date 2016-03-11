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
                    avatarView.af_setImageWithURL(NSURL(string:avatarUrl)!, placeholderImage: UIImage(named: "speaker"))
                } else {
                    avatarView.image = UIImage(named: "speaker")
                }
            } else {
                avatarView.image = UIImage(named: "speaker")
                nameLabel.text = ""
            }
        }
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.nameLabel.textColor = UIColor(red: 245/255.0, green: 175/255.0, blue: 51/255.0, alpha: 1.0)
                self.nameLabel.frame.origin.y += 40
                }, completion: nil)
        } else {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.nameLabel.textColor = UIColor.whiteColor()
                self.nameLabel.frame.origin.y -= 40
                }, completion: nil)
        }
    }
}
