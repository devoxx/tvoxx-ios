//
//  TalkDetailViewController.swift
//  TVoxx
//
//  Created by Sebastien Arbogast on 05/03/2016.
//  Copyright © 2016 Epseelon. All rights reserved.
//

import UIKit
import Cosmos
import AlamofireImage

class TalkDetailViewController: UIViewController {
    @IBOutlet weak var loadingView: UIStackView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var conferenceLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var ratingGroup: UIStackView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var detailView: UIStackView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var abstractLabel: UILabel!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var addToWatchlistButton: UIButton!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var speakersCollectionView: UICollectionView!
    
    var talk: TalkListItem? {
        didSet {
            guard self.loadingLabel != nil else { return }
            if let talk = self.talk {
                self.loadingLabel.text = talk.title + "..."
            } else {
                self.loadingLabel.text = ""
            }
        }
    }
    private var talkDetail:TalkDetail?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.ratingView.settings.fillMode = .Precise
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.titleLabel.hidden = true
        self.detailView.hidden = true
        self.speakersCollectionView.hidden = true
        
        if let talk = self.talk {
            self.loadingView.hidden = false
            self.loadingLabel.text = talk.title + "..."
            self.loadingIndicator.startAnimating()
            TVoxxServer.sharedServer.getTalkWithTalkId(talk.talkId) { (talkDetail: TalkDetail) in
                self.talkDetail = talkDetail
                self.titleLabel.text = talkDetail.title
                self.formatLabel.text = talkDetail.talkType
                self.conferenceLabel.text = talkDetail.conferenceLabel.stringByReplacingOccurrencesOfString(", ", withString: ",\n")
                self.trackLabel.text = talkDetail.trackTitle
                if let rating = talkDetail.averageRating {
                    self.ratingView.rating = rating
                    self.ratingLabel.text = String(format: NSLocalizedString("Out of %d votes", comment:""), talkDetail.numberOfRatings!)
                    self.ratingGroup.hidden = false
                } else {
                    self.ratingGroup.hidden = true
                }
                self.abstractLabel.text = talkDetail.summary
                self.languageLabel.text = NSLocale.currentLocale().displayNameForKey(NSLocaleIdentifier, value: talkDetail.lang)
                self.thumbnailView.af_setImageWithURL(NSURL(string: talkDetail.thumbnailUrl)!)
                self.durationLabel.text = talkDetail.duration
                
                self.loadingView.hidden = true
                self.loadingLabel.hidden = true
                self.titleLabel.hidden = false
                self.detailView.hidden = false
                self.speakersCollectionView.hidden = false
            }
        } else {
            self.loadingView.hidden = true
            self.loadingLabel.text = NSLocalizedString("No talk to load", comment: "")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override var preferredFocusedView: UIView? {
        return self.playButton
    }

}
