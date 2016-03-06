//
//  TalkCollectionViewCell.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 02/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import Cosmos

class TalkCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel:UILabel!
    @IBOutlet weak var imageView:UIImageView!
    
    var talk: TalkListItem? {
        didSet {
            if let talk = talk {
                self.titleLabel.text = talk.title
                self.imageView.af_setImageWithURL(NSURL(string: talk.thumbnailUrl)!)
            } else {
                self.titleLabel.text = ""
                self.imageView.image = nil
            }
        }
    }
    
    override func didUpdateFocusInContext(context: UIFocusUpdateContext, withAnimationCoordinator coordinator: UIFocusAnimationCoordinator) {
        if context.nextFocusedView == self {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.titleLabel.textColor = UIColor(red: 245/255.0, green: 175/255.0, blue: 51/255.0, alpha: 1.0)
                self.titleLabel.frame.origin.y += 40
                }, completion: nil)
        } else {
            coordinator.addCoordinatedAnimations({ () -> Void in
                self.titleLabel.textColor = UIColor.whiteColor()
                self.titleLabel.frame.origin.y -= 40
                }, completion: nil)
        }
    }
}
